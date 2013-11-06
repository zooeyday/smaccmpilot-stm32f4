{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE MultiParamTypeClasses #-}

-- Autogenerated Mavlink v1.0 implementation: see smavgen_ivory.py

module SMACCMPilot.Mavlink.Messages.Ping where

import SMACCMPilot.Mavlink.Pack
import SMACCMPilot.Mavlink.Unpack
import SMACCMPilot.Mavlink.Send
import qualified SMACCMPilot.Communications as Comm

import Ivory.Language
import Ivory.Stdlib

pingMsgId :: Uint8
pingMsgId = 4

pingCrcExtra :: Uint8
pingCrcExtra = 237

pingModule :: Module
pingModule = package "mavlink_ping_msg" $ do
  depend packModule
  depend mavlinkSendModule
  incl mkPingSender
  incl pingUnpack
  defStruct (Proxy :: Proxy "ping_msg")

[ivory|
struct ping_msg
  { time_usec :: Stored Uint64
  ; ping_seq :: Stored Uint32
  ; target_system :: Stored Uint8
  ; target_component :: Stored Uint8
  }
|]

mkPingSender ::
  Def ('[ ConstRef s0 (Struct "ping_msg")
        , Ref s1 (Stored Uint8) -- seqNum
        , Ref s1 Comm.MAVLinkArray -- tx buffer
        ] :-> ())
mkPingSender =
  proc "mavlink_ping_msg_send"
  $ \msg seqNum sendArr -> body
  $ do
  arr <- local (iarray [] :: Init (Array 14 (Stored Uint8)))
  let buf = toCArray arr
  call_ pack buf 0 =<< deref (msg ~> time_usec)
  call_ pack buf 8 =<< deref (msg ~> ping_seq)
  call_ pack buf 12 =<< deref (msg ~> target_system)
  call_ pack buf 13 =<< deref (msg ~> target_component)
  -- 6: header len, 2: CRC len
  let usedLen = 6 + 14 + 2 :: Integer
  let sendArrLen = arrayLen sendArr
  if sendArrLen < usedLen
    then error "ping payload of length 14 is too large!"
    else do -- Copy, leaving room for the payload
            arrCopy sendArr arr 6
            call_ mavlinkSendWithWriter
                    pingMsgId
                    pingCrcExtra
                    14
                    seqNum
                    sendArr

instance MavlinkUnpackableMsg "ping_msg" where
    unpackMsg = ( pingUnpack , pingMsgId )

pingUnpack :: Def ('[ Ref s1 (Struct "ping_msg")
                             , ConstRef s2 (CArray (Stored Uint8))
                             ] :-> () )
pingUnpack = proc "mavlink_ping_unpack" $ \ msg buf -> body $ do
  store (msg ~> time_usec) =<< call unpack buf 0
  store (msg ~> ping_seq) =<< call unpack buf 8
  store (msg ~> target_system) =<< call unpack buf 12
  store (msg ~> target_component) =<< call unpack buf 13

