{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE MultiParamTypeClasses #-}

-- Autogenerated Mavlink v1.0 implementation: see smavgen_ivory.py

module SMACCMPilot.Mavlink.Messages.Debug where

import SMACCMPilot.Mavlink.Pack
import SMACCMPilot.Mavlink.Unpack
import SMACCMPilot.Mavlink.Send
import qualified SMACCMPilot.Communications as Comm

import Ivory.Language
import Ivory.Stdlib

debugMsgId :: Uint8
debugMsgId = 254

debugCrcExtra :: Uint8
debugCrcExtra = 46

debugModule :: Module
debugModule = package "mavlink_debug_msg" $ do
  depend packModule
  depend mavlinkSendModule
  incl mkDebugSender
  incl debugUnpack
  defStruct (Proxy :: Proxy "debug_msg")

[ivory|
struct debug_msg
  { time_boot_ms :: Stored Uint32
  ; value :: Stored IFloat
  ; ind :: Stored Uint8
  }
|]

mkDebugSender ::
  Def ('[ ConstRef s0 (Struct "debug_msg")
        , Ref s1 (Stored Uint8) -- seqNum
        , Ref s1 Comm.MAVLinkArray -- tx buffer
        ] :-> ())
mkDebugSender =
  proc "mavlink_debug_msg_send"
  $ \msg seqNum sendArr -> body
  $ do
  arr <- local (iarray [] :: Init (Array 9 (Stored Uint8)))
  let buf = toCArray arr
  call_ pack buf 0 =<< deref (msg ~> time_boot_ms)
  call_ pack buf 4 =<< deref (msg ~> value)
  call_ pack buf 8 =<< deref (msg ~> ind)
  -- 6: header len, 2: CRC len
  let usedLen = 6 + 9 + 2 :: Integer
  let sendArrLen = arrayLen sendArr
  if sendArrLen < usedLen
    then error "debug payload of length 9 is too large!"
    else do -- Copy, leaving room for the payload
            arrCopy sendArr arr 6
            call_ mavlinkSendWithWriter
                    debugMsgId
                    debugCrcExtra
                    9
                    seqNum
                    sendArr
            let usedLenIx = fromInteger usedLen
            -- Zero out the unused portion of the array.
            for (fromInteger sendArrLen - usedLenIx) $ \ix ->
              store (sendArr ! (ix + usedLenIx)) 0
            retVoid

instance MavlinkUnpackableMsg "debug_msg" where
    unpackMsg = ( debugUnpack , debugMsgId )

debugUnpack :: Def ('[ Ref s1 (Struct "debug_msg")
                             , ConstRef s2 (CArray (Stored Uint8))
                             ] :-> () )
debugUnpack = proc "mavlink_debug_unpack" $ \ msg buf -> body $ do
  store (msg ~> time_boot_ms) =<< call unpack buf 0
  store (msg ~> value) =<< call unpack buf 4
  store (msg ~> ind) =<< call unpack buf 8

