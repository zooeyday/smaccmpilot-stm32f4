{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE MultiParamTypeClasses #-}

-- Autogenerated Mavlink v1.0 implementation: see smavgen_ivory.py

module SMACCMPilot.Mavlink.Messages.Data64 where

import SMACCMPilot.Mavlink.Pack
import SMACCMPilot.Mavlink.Unpack
import SMACCMPilot.Mavlink.Send
import qualified SMACCMPilot.Communications as Comm

import Ivory.Language
import Ivory.Stdlib

data64MsgId :: Uint8
data64MsgId = 171

data64CrcExtra :: Uint8
data64CrcExtra = 170

data64Module :: Module
data64Module = package "mavlink_data64_msg" $ do
  depend packModule
  depend mavlinkSendModule
  incl mkData64Sender
  incl data64Unpack
  defStruct (Proxy :: Proxy "data64_msg")

[ivory|
struct data64_msg
  { data64_type :: Stored Uint8
  ; len :: Stored Uint8
  ; data64 :: Array 64 (Stored Uint8)
  }
|]

mkData64Sender ::
  Def ('[ ConstRef s0 (Struct "data64_msg")
        , Ref s1 (Stored Uint8) -- seqNum
        , Ref s1 Comm.MAVLinkArray -- tx buffer
        ] :-> ())
mkData64Sender =
  proc "mavlink_data64_msg_send"
  $ \msg seqNum sendArr -> body
  $ do
  arr <- local (iarray [] :: Init (Array 66 (Stored Uint8)))
  let buf = toCArray arr
  call_ pack buf 0 =<< deref (msg ~> data64_type)
  call_ pack buf 1 =<< deref (msg ~> len)
  arrayPack buf 2 (msg ~> data64)
  -- 6: header len, 2: CRC len
  let usedLen = 6 + 66 + 2 :: Integer
  let sendArrLen = arrayLen sendArr
  if sendArrLen < usedLen
    then error "data64 payload of length 66 is too large!"
    else do -- Copy, leaving room for the payload
            arrCopy sendArr arr 6
            call_ mavlinkSendWithWriter
                    data64MsgId
                    data64CrcExtra
                    66
                    seqNum
                    sendArr

instance MavlinkUnpackableMsg "data64_msg" where
    unpackMsg = ( data64Unpack , data64MsgId )

data64Unpack :: Def ('[ Ref s1 (Struct "data64_msg")
                             , ConstRef s2 (CArray (Stored Uint8))
                             ] :-> () )
data64Unpack = proc "mavlink_data64_unpack" $ \ msg buf -> body $ do
  store (msg ~> data64_type) =<< call unpack buf 0
  store (msg ~> len) =<< call unpack buf 1
  arrayUnpack buf 2 (msg ~> data64)

