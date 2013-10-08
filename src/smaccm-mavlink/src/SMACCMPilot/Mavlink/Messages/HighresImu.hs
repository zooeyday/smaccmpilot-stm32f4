{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE MultiParamTypeClasses #-}

-- Autogenerated Mavlink v1.0 implementation: see smavgen_ivory.py

module SMACCMPilot.Mavlink.Messages.HighresImu where

import SMACCMPilot.Mavlink.Pack
import SMACCMPilot.Mavlink.Unpack
import SMACCMPilot.Mavlink.Send
import qualified SMACCMPilot.Communications as Comm

import Ivory.Language
import Ivory.Stdlib

highresImuMsgId :: Uint8
highresImuMsgId = 105

highresImuCrcExtra :: Uint8
highresImuCrcExtra = 93

highresImuModule :: Module
highresImuModule = package "mavlink_highres_imu_msg" $ do
  depend packModule
  depend mavlinkSendModule
  incl mkHighresImuSender
  incl highresImuUnpack
  defStruct (Proxy :: Proxy "highres_imu_msg")

[ivory|
struct highres_imu_msg
  { time_usec :: Stored Uint64
  ; xacc :: Stored IFloat
  ; yacc :: Stored IFloat
  ; zacc :: Stored IFloat
  ; xgyro :: Stored IFloat
  ; ygyro :: Stored IFloat
  ; zgyro :: Stored IFloat
  ; xmag :: Stored IFloat
  ; ymag :: Stored IFloat
  ; zmag :: Stored IFloat
  ; abs_pressure :: Stored IFloat
  ; diff_pressure :: Stored IFloat
  ; pressure_alt :: Stored IFloat
  ; temperature :: Stored IFloat
  ; fields_updated :: Stored Uint16
  }
|]

mkHighresImuSender ::
  Def ('[ ConstRef s0 (Struct "highres_imu_msg")
        , Ref s1 (Stored Uint8) -- seqNum
        , Ref s1 Comm.MAVLinkArray -- tx buffer
        ] :-> ())
mkHighresImuSender =
  proc "mavlink_highres_imu_msg_send"
  $ \msg seqNum sendArr -> body
  $ do
  arr <- local (iarray [] :: Init (Array 62 (Stored Uint8)))
  let buf = toCArray arr
  call_ pack buf 0 =<< deref (msg ~> time_usec)
  call_ pack buf 8 =<< deref (msg ~> xacc)
  call_ pack buf 12 =<< deref (msg ~> yacc)
  call_ pack buf 16 =<< deref (msg ~> zacc)
  call_ pack buf 20 =<< deref (msg ~> xgyro)
  call_ pack buf 24 =<< deref (msg ~> ygyro)
  call_ pack buf 28 =<< deref (msg ~> zgyro)
  call_ pack buf 32 =<< deref (msg ~> xmag)
  call_ pack buf 36 =<< deref (msg ~> ymag)
  call_ pack buf 40 =<< deref (msg ~> zmag)
  call_ pack buf 44 =<< deref (msg ~> abs_pressure)
  call_ pack buf 48 =<< deref (msg ~> diff_pressure)
  call_ pack buf 52 =<< deref (msg ~> pressure_alt)
  call_ pack buf 56 =<< deref (msg ~> temperature)
  call_ pack buf 60 =<< deref (msg ~> fields_updated)
  -- 6: header len, 2: CRC len
  let usedLen = 6 + 62 + 2 :: Integer
  let sendArrLen = arrayLen sendArr
  if sendArrLen < usedLen
    then error "highresImu payload of length 62 is too large!"
    else do -- Copy, leaving room for the payload
            arrCopy sendArr arr 6
            call_ mavlinkSendWithWriter
                    highresImuMsgId
                    highresImuCrcExtra
                    62
                    seqNum
                    sendArr
            let usedLenIx = fromInteger usedLen
            -- Zero out the unused portion of the array.
            for (fromInteger sendArrLen - usedLenIx) $ \ix ->
              store (sendArr ! (ix + usedLenIx)) 0
            retVoid

instance MavlinkUnpackableMsg "highres_imu_msg" where
    unpackMsg = ( highresImuUnpack , highresImuMsgId )

highresImuUnpack :: Def ('[ Ref s1 (Struct "highres_imu_msg")
                             , ConstRef s2 (CArray (Stored Uint8))
                             ] :-> () )
highresImuUnpack = proc "mavlink_highres_imu_unpack" $ \ msg buf -> body $ do
  store (msg ~> time_usec) =<< call unpack buf 0
  store (msg ~> xacc) =<< call unpack buf 8
  store (msg ~> yacc) =<< call unpack buf 12
  store (msg ~> zacc) =<< call unpack buf 16
  store (msg ~> xgyro) =<< call unpack buf 20
  store (msg ~> ygyro) =<< call unpack buf 24
  store (msg ~> zgyro) =<< call unpack buf 28
  store (msg ~> xmag) =<< call unpack buf 32
  store (msg ~> ymag) =<< call unpack buf 36
  store (msg ~> zmag) =<< call unpack buf 40
  store (msg ~> abs_pressure) =<< call unpack buf 44
  store (msg ~> diff_pressure) =<< call unpack buf 48
  store (msg ~> pressure_alt) =<< call unpack buf 52
  store (msg ~> temperature) =<< call unpack buf 56
  store (msg ~> fields_updated) =<< call unpack buf 60

