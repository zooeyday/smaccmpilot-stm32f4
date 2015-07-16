{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE TypeFamilies #-}

module SMACCMPilot.Flight.IO.PPM.Decode
  ( PPMDecoder(..)
  , monitorPPMDecoder
  ) where

import Ivory.Language
import Ivory.Tower
import Ivory.Stdlib
import Control.Monad (forM_)

import qualified SMACCMPilot.Comm.Ivory.Types.RcInput   as RC
import qualified SMACCMPilot.Comm.Ivory.Types.UserInput as I
import qualified SMACCMPilot.Comm.Ivory.Types.ControlLaw as C

import SMACCMPilot.Time
import SMACCMPilot.Flight.IO.PPM.ModeSwitch
import SMACCMPilot.Flight.IO.PPM.ArmingMachine

data PPMDecoder =
  PPMDecoder
    { ppmd_init       :: forall eff    . Ivory eff ()
    , ppmd_no_sample  :: forall eff    . ITime -> Ivory eff ()
    , ppmd_new_sample :: forall eff s  . ConstRef s (Struct "rc_input")
                                      -> Ivory eff ()
    , ppmd_get_ui     :: forall eff cs . (GetAlloc eff ~ Scope cs)
         => Ivory eff (ConstRef (Stack cs) (Struct "user_input"))
    , ppmd_get_cl_req :: forall eff cs . (GetAlloc eff ~ Scope cs)
         => Ivory eff (ConstRef (Stack cs) (Struct "control_law"))
    }

monitorPPMDecoder :: Monitor e PPMDecoder
monitorPPMDecoder = do
  let named n = fmap showUnique $ freshname $ "ppmdecoder_" ++ n
  rcin_last             <- state "rcin_last"
  let ppm_valid = rcin_last ~> RC.valid
      ppm_last  = rcin_last
      ppm_last_time = rcin_last ~> RC.time

  modeswitch    <- monitorModeSwitch
  armingmachine <- monitorArmingMachine

  init_name <- named "init"
  new_sample_name <- named "new_sample"
  no_sample_name <- named "no_sample"
  get_ui_name <- named "get_ui"
  get_cl_req_name <- named "gel_cl_req"

  let init_proc :: Def('[]:->())
      init_proc = proc init_name $ body $ do
        ms_init modeswitch


      invalidate :: Ivory eff ()
      invalidate = do
          store ppm_valid false
          ms_no_sample modeswitch
          am_no_sample armingmachine

      new_sample_proc :: Def('[ConstRef s (Struct "rc_input") ]:->())
      new_sample_proc = proc new_sample_name $ \rc_in -> body $ do
        time <- deref (rc_in ~> RC.time)
        all_good <- local (ival true)

        forM_ chan_labels $ \lbl -> do
          ch <- deref (rc_in ~> lbl)
          unless (ch >=? minBound .&& ch <=? maxBound)
                 (store all_good false)

        s <- deref all_good
        unless s $ invalidate
        when   s $ do
          forM_ chan_labels $ \lbl -> do
            (deref (rc_in ~> lbl) >>= store (rcin_last ~> lbl))
          store ppm_last_time time
          store ppm_valid true
          ms_new_sample modeswitch    rc_in
          am_new_sample armingmachine rc_in

      no_sample_proc :: Def('[ITime]:->())
      no_sample_proc = proc no_sample_name $ \time -> body $ do
        prev <- fmap iTimeFromTimeMicros (deref ppm_last_time)
        when ((time - prev) >? timeout_limit) invalidate

      get_ui_proc :: Def('[Ref s (Struct "user_input")]:->())
      get_ui_proc = proc get_ui_name $ \ui -> body $ do
        valid <- deref ppm_valid
        time <- fmap iTimeFromTimeMicros (deref ppm_last_time)
        ifte_ valid
          (call_  ppm_decode_ui_proc (constRef ppm_last) ui time)
          (failsafe ui)

      get_cl_req_proc :: Def('[Ref s (Struct "control_law")]:->())
      get_cl_req_proc = proc get_cl_req_name $ \cl_req -> body $ do
        ms_get_cl_req modeswitch cl_req
        am_get_cl_req armingmachine (cl_req ~> C.arming_mode)

  monitorModuleDef $ do
    incl init_proc
    incl new_sample_proc
    incl no_sample_proc
    incl get_ui_proc
    incl get_cl_req_proc
    incl scale_proc
    incl ppm_decode_ui_proc

  return PPMDecoder
    { ppmd_init       = call_ init_proc
    , ppmd_new_sample = call_ new_sample_proc
    , ppmd_no_sample  = call_ no_sample_proc
    , ppmd_get_ui     = do
        l <- local (istruct [])
        call_ get_ui_proc l
        return (constRef l)
    , ppmd_get_cl_req = do
        l <- local (istruct [])
        call_ get_cl_req_proc l
        return (constRef l)
    }
  where
  timeout_limit = fromIMilliseconds (150 :: Uint8)-- ms
  chan_labels = [ RC.roll, RC.pitch, RC.throttle, RC.yaw, RC.switch1, RC.switch2 ]

failsafe :: Ref s (Struct "user_input") -> Ivory eff ()
failsafe ui = do
  store (ui ~> I.roll)      0
  store (ui ~> I.pitch)     0
  store (ui ~> I.throttle) (-1)
  store (ui ~> I.yaw)       0

scale_ppm_channel :: Uint16 -> Ivory eff IFloat
scale_ppm_channel input = call scale_proc center range outmin outmax input
  where
  center = 1500
  range = 500
  outmin = -1.0
  outmax = 1.0



scale_proc :: Def ('[Uint16, Uint16, IFloat, IFloat, Uint16] :-> IFloat)
scale_proc = proc "ppm_scale_proc" $ \center range outmin outmax input ->
  requires (    (range /=? 0)
            .&& (input >=? minBound)
            .&& (input <=? maxBound)
           )
  $ body $ do
    let centered = safeCast input - safeCast center
    let ranged = centered / safeCast range
    ifte_ (ranged <? outmin)
      (ret outmin)
      (ifte_ (ranged >? outmax)
        (ret outmax)
        (ret ranged))

ppm_decode_ui_proc :: Def ('[ ConstRef s0 (Struct "rc_input")
                            , Ref s1 (Struct "user_input")
                            , ITime
                            ] :-> ())
ppm_decode_ui_proc = proc "ppm_decode_userinput" $ \rcin ui _now ->
  body $ do
  -- Scale 1000-2000 inputs to -1 to 1 inputs.
  let chtransform :: Label "rc_input" (Stored Uint16)
                  -> Label "user_input" (Stored IFloat)
                  -> Ivory eff ()
      chtransform rcfield ofield = do
        ppm <- deref (rcin ~> rcfield)
        v   <- scale_ppm_channel ppm
        store (ui ~> ofield) v
  chtransform RC.roll     I.roll
  chtransform RC.pitch    I.pitch
  chtransform RC.throttle I.throttle
  chtransform RC.yaw      I.yaw
  retVoid

