{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE MultiParamTypeClasses #-}

-- Autogenerated Mavlink v1.0 implementation: see smavlink_ivory.py

module SMACCMPilot.Mavlink.Messages.RawPressure where

import SMACCMPilot.Mavlink.Pack
import SMACCMPilot.Mavlink.Unpack
import SMACCMPilot.Mavlink.Send

import Ivory.Language

rawPressureMsgId :: Uint8
rawPressureMsgId = 28

rawPressureCrcExtra :: Uint8
rawPressureCrcExtra = 67

rawPressureModule :: Module
rawPressureModule = package "mavlink_raw_pressure_msg" $ do
  depend packModule
  incl rawPressureUnpack
  defStruct (Proxy :: Proxy "raw_pressure_msg")

[ivory|
struct raw_pressure_msg
  { time_usec :: Stored Uint64
  ; press_abs :: Stored Sint16
  ; press_diff1 :: Stored Sint16
  ; press_diff2 :: Stored Sint16
  ; temperature :: Stored Sint16
  }
|]

mkRawPressureSender :: SizedMavlinkSender 16
                       -> Def ('[ ConstRef s (Struct "raw_pressure_msg") ] :-> ())
mkRawPressureSender sender =
  proc ("mavlink_raw_pressure_msg_send" ++ (senderName sender)) $ \msg -> body $ do
    rawPressurePack (senderMacro sender) msg

instance MavlinkSendable "raw_pressure_msg" 16 where
  mkSender = mkRawPressureSender

rawPressurePack :: (eff `AllocsIn` s, eff `Returns` ())
                  => SenderMacro eff s 16
                  -> ConstRef s1 (Struct "raw_pressure_msg")
                  -> Ivory eff ()
rawPressurePack sender msg = do
  arr <- local (iarray [] :: Init (Array 16 (Stored Uint8)))
  let buf = toCArray arr
  call_ pack buf 0 =<< deref (msg ~> time_usec)
  call_ pack buf 8 =<< deref (msg ~> press_abs)
  call_ pack buf 10 =<< deref (msg ~> press_diff1)
  call_ pack buf 12 =<< deref (msg ~> press_diff2)
  call_ pack buf 14 =<< deref (msg ~> temperature)
  sender rawPressureMsgId (constRef arr) rawPressureCrcExtra
  retVoid

instance MavlinkUnpackableMsg "raw_pressure_msg" where
    unpackMsg = ( rawPressureUnpack , rawPressureMsgId )

rawPressureUnpack :: Def ('[ Ref s1 (Struct "raw_pressure_msg")
                             , ConstRef s2 (CArray (Stored Uint8))
                             ] :-> () )
rawPressureUnpack = proc "mavlink_raw_pressure_unpack" $ \ msg buf -> body $ do
  store (msg ~> time_usec) =<< call unpack buf 0
  store (msg ~> press_abs) =<< call unpack buf 8
  store (msg ~> press_diff1) =<< call unpack buf 10
  store (msg ~> press_diff2) =<< call unpack buf 12
  store (msg ~> temperature) =<< call unpack buf 14
