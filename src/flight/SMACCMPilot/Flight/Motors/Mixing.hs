{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE DataKinds #-}

module SMACCMPilot.Flight.Motors.Mixing
  ( throttlePassthrough
  , mixer
  ) where

import Ivory.Language
import Ivory.Stdlib

import qualified SMACCMPilot.Flight.Types.ControlOutput as C
import qualified SMACCMPilot.Flight.Types.Motors        as M

throttlePassthrough :: (GetAlloc eff ~ Scope cs)
      => ConstRef s1 (Struct "controloutput")
      -> Ivory eff (ConstRef (Stack cs) (Struct "motors"))
throttlePassthrough control = do
  t <- deref (control ~> C.throttle)
  out <- local (istruct [ M.frontleft  .= ival t
                        , M.frontright .= ival t
                        , M.backleft   .= ival t
                        , M.backright  .= ival t
                        ])
  return (constRef out)


idle :: IFloat
idle = 0.07

mixer :: (GetAlloc eff ~ Scope cs)
      => ConstRef s1 (Struct "controloutput")
      -> Ivory eff (ConstRef (Stack cs) (Struct "motors"))
mixer control = do
  throttle <- deref (control ~> C.throttle)
  pitch    <- deref (control ~> C.pitch)
  roll     <- deref (control ~> C.roll)
  yaw      <- deref (control ~> C.yaw)
  o1 <- axis_mix throttle pitch roll yaw
  o2 <- throttle_floor throttle o1
  o3 <- sane_range o2
  return (constRef o3)

axis_mix :: (GetAlloc eff ~ Scope cs)
          => IFloat -- Throttle
          -> IFloat -- Pitch
          -> IFloat -- Roll
          -> IFloat -- Yaw
          -> Ivory eff (Ref (Stack cs) (Struct "motors"))
axis_mix throttle pitch roll yaw = do
  fl <- assign $ throttle + p + r - y
  fr <- assign $ throttle + p - r + y
  bl <- assign $ throttle - p + r + y
  br <- assign $ throttle - p - r - y
  lowbound <- assign $ floor4 fl fr bl br
  hibound  <- assign $ ceil4  fl fr bl br
  adj      <- assign $ motor_adj lowbound hibound
  local (istruct [ M.frontleft  .= ival (fl + adj)
                 , M.frontright .= ival (fr + adj)
                 , M.backleft   .= ival (bl + adj)
                 , M.backright  .= ival (br + adj)
                 ])
  where
  (y, _yextra) = yaw_constrain yaw (imax 0.1 (throttle/3))
  p = 0.75 * pitch
  r = 0.75 * roll

  motor_adj :: IFloat -> IFloat -> IFloat
  motor_adj lowbound hibound =
    -- If largest motor is higher than 1.0, drop down so that motor is at 1.0
    -- Note that this may mean the lowest motor slips under idle
    (hibound >? 1.0) ? ((1.0-hibound)
      -- If lowest motor is lower than idle, raise so that motor is at idle
     ,(lowbound <? idle) ? ((idle-lowbound)
       -- If all motors are in bounds, do not adjust
      ,0.0))

yaw_constrain :: IFloat -> IFloat -> (IFloat, IFloat)
yaw_constrain input threshold =
  ( regions threshold           (-1*threshold)      input
  , regions (input - threshold) (input + threshold) 0.0)
  where
  regions over under inside =
    (input >? threshold) ? (over
     ,(input <? (-1*threshold)) ? (under
       ,inside))


throttle_floor :: IFloat -> Ref s (Struct "motors") -> Ivory eff (Ref s (Struct "motors"))
throttle_floor thr input = do
  when (thr <? idle) $ setzero input
  return input
  where
  setzero i = do
    store (i ~> M.frontleft)  0
    store (i ~> M.frontright) 0
    store (i ~> M.backleft)   0
    store (i ~> M.backright)  0

sane_range :: Ref s (Struct "motors") -> Ivory eff (Ref s (Struct "motors"))
sane_range i = do
  sane $ i ~> M.frontleft
  sane $ i ~> M.frontright
  sane $ i ~> M.backleft
  sane $ i ~> M.backright
  return i
  where
  sane accessor = do
    v <- deref accessor
    ifte_ (v <? 0.0) (store accessor 0)
      (ifte_ (v >? 1.0) (store accessor 1.0)
       (return ()))

imin :: IvoryOrd a => a -> a -> a
imin a b = (a <? b)?(a,b)

imax :: IvoryOrd a => a -> a -> a
imax a b = (a >? b)?(a,b)

floor4 :: (IvoryOrd a) => a -> a -> a -> a -> a
floor4 a b c d = imin a (imin b (imin c d))
ceil4 :: (IvoryOrd a) => a -> a -> a -> a -> a
ceil4  a b c d = imax a (imax b (imax c d))