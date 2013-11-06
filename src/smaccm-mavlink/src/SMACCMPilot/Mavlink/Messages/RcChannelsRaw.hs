{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE MultiParamTypeClasses #-}

-- Autogenerated Mavlink v1.0 implementation: see smavgen_ivory.py

module SMACCMPilot.Mavlink.Messages.RcChannelsRaw where

import SMACCMPilot.Mavlink.Pack
import SMACCMPilot.Mavlink.Unpack
import SMACCMPilot.Mavlink.Send
import qualified SMACCMPilot.Communications as Comm

import Ivory.Language
import Ivory.Stdlib

rcChannelsRawMsgId :: Uint8
rcChannelsRawMsgId = 35

rcChannelsRawCrcExtra :: Uint8
rcChannelsRawCrcExtra = 244

rcChannelsRawModule :: Module
rcChannelsRawModule = package "mavlink_rc_channels_raw_msg" $ do
  depend packModule
  depend mavlinkSendModule
  incl mkRcChannelsRawSender
  incl rcChannelsRawUnpack
  defStruct (Proxy :: Proxy "rc_channels_raw_msg")

[ivory|
struct rc_channels_raw_msg
  { time_boot_ms :: Stored Uint32
  ; chan1_raw :: Stored Uint16
  ; chan2_raw :: Stored Uint16
  ; chan3_raw :: Stored Uint16
  ; chan4_raw :: Stored Uint16
  ; chan5_raw :: Stored Uint16
  ; chan6_raw :: Stored Uint16
  ; chan7_raw :: Stored Uint16
  ; chan8_raw :: Stored Uint16
  ; port :: Stored Uint8
  ; rssi :: Stored Uint8
  }
|]

mkRcChannelsRawSender ::
  Def ('[ ConstRef s0 (Struct "rc_channels_raw_msg")
        , Ref s1 (Stored Uint8) -- seqNum
        , Ref s1 Comm.MAVLinkArray -- tx buffer
        ] :-> ())
mkRcChannelsRawSender =
  proc "mavlink_rc_channels_raw_msg_send"
  $ \msg seqNum sendArr -> body
  $ do
  arr <- local (iarray [] :: Init (Array 22 (Stored Uint8)))
  let buf = toCArray arr
  call_ pack buf 0 =<< deref (msg ~> time_boot_ms)
  call_ pack buf 4 =<< deref (msg ~> chan1_raw)
  call_ pack buf 6 =<< deref (msg ~> chan2_raw)
  call_ pack buf 8 =<< deref (msg ~> chan3_raw)
  call_ pack buf 10 =<< deref (msg ~> chan4_raw)
  call_ pack buf 12 =<< deref (msg ~> chan5_raw)
  call_ pack buf 14 =<< deref (msg ~> chan6_raw)
  call_ pack buf 16 =<< deref (msg ~> chan7_raw)
  call_ pack buf 18 =<< deref (msg ~> chan8_raw)
  call_ pack buf 20 =<< deref (msg ~> port)
  call_ pack buf 21 =<< deref (msg ~> rssi)
  -- 6: header len, 2: CRC len
  let usedLen = 6 + 22 + 2 :: Integer
  let sendArrLen = arrayLen sendArr
  if sendArrLen < usedLen
    then error "rcChannelsRaw payload of length 22 is too large!"
    else do -- Copy, leaving room for the payload
            arrCopy sendArr arr 6
            call_ mavlinkSendWithWriter
                    rcChannelsRawMsgId
                    rcChannelsRawCrcExtra
                    22
                    seqNum
                    sendArr

instance MavlinkUnpackableMsg "rc_channels_raw_msg" where
    unpackMsg = ( rcChannelsRawUnpack , rcChannelsRawMsgId )

rcChannelsRawUnpack :: Def ('[ Ref s1 (Struct "rc_channels_raw_msg")
                             , ConstRef s2 (CArray (Stored Uint8))
                             ] :-> () )
rcChannelsRawUnpack = proc "mavlink_rc_channels_raw_unpack" $ \ msg buf -> body $ do
  store (msg ~> time_boot_ms) =<< call unpack buf 0
  store (msg ~> chan1_raw) =<< call unpack buf 4
  store (msg ~> chan2_raw) =<< call unpack buf 6
  store (msg ~> chan3_raw) =<< call unpack buf 8
  store (msg ~> chan4_raw) =<< call unpack buf 10
  store (msg ~> chan5_raw) =<< call unpack buf 12
  store (msg ~> chan6_raw) =<< call unpack buf 14
  store (msg ~> chan7_raw) =<< call unpack buf 16
  store (msg ~> chan8_raw) =<< call unpack buf 18
  store (msg ~> port) =<< call unpack buf 20
  store (msg ~> rssi) =<< call unpack buf 21

