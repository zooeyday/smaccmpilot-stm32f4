{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE MultiParamTypeClasses #-}

-- Autogenerated Mavlink v1.0 implementation: see smavgen_ivory.py

module SMACCMPilot.Mavlink.Messages.MemoryVect where

import SMACCMPilot.Mavlink.Pack
import SMACCMPilot.Mavlink.Unpack
import SMACCMPilot.Mavlink.Send
import qualified SMACCMPilot.Communications as Comm

import Ivory.Language
import Ivory.Stdlib

memoryVectMsgId :: Uint8
memoryVectMsgId = 249

memoryVectCrcExtra :: Uint8
memoryVectCrcExtra = 204

memoryVectModule :: Module
memoryVectModule = package "mavlink_memory_vect_msg" $ do
  depend packModule
  depend mavlinkSendModule
  incl mkMemoryVectSender
  incl memoryVectUnpack
  defStruct (Proxy :: Proxy "memory_vect_msg")

[ivory|
struct memory_vect_msg
  { address :: Stored Uint16
  ; ver :: Stored Uint8
  ; memory_vect_type :: Stored Uint8
  ; value :: Array 32 (Stored Sint8)
  }
|]

mkMemoryVectSender ::
  Def ('[ ConstRef s0 (Struct "memory_vect_msg")
        , Ref s1 (Stored Uint8) -- seqNum
        , Ref s1 Comm.MAVLinkArray -- tx buffer
        ] :-> ())
mkMemoryVectSender =
  proc "mavlink_memory_vect_msg_send"
  $ \msg seqNum sendArr -> body
  $ do
  arr <- local (iarray [] :: Init (Array 36 (Stored Uint8)))
  let buf = toCArray arr
  call_ pack buf 0 =<< deref (msg ~> address)
  call_ pack buf 2 =<< deref (msg ~> ver)
  call_ pack buf 3 =<< deref (msg ~> memory_vect_type)
  arrayPack buf 4 (msg ~> value)
  -- 6: header len, 2: CRC len
  let usedLen = 6 + 36 + 2 :: Integer
  let sendArrLen = arrayLen sendArr
  if sendArrLen < usedLen
    then error "memoryVect payload of length 36 is too large!"
    else do -- Copy, leaving room for the payload
            arrCopy sendArr arr 6
            call_ mavlinkSendWithWriter
                    memoryVectMsgId
                    memoryVectCrcExtra
                    36
                    seqNum
                    sendArr
            let usedLenIx = fromInteger usedLen
            -- Zero out the unused portion of the array.
            for (fromInteger sendArrLen - usedLenIx) $ \ix ->
              store (sendArr ! (ix + usedLenIx)) 0
            retVoid

instance MavlinkUnpackableMsg "memory_vect_msg" where
    unpackMsg = ( memoryVectUnpack , memoryVectMsgId )

memoryVectUnpack :: Def ('[ Ref s1 (Struct "memory_vect_msg")
                             , ConstRef s2 (CArray (Stored Uint8))
                             ] :-> () )
memoryVectUnpack = proc "mavlink_memory_vect_unpack" $ \ msg buf -> body $ do
  store (msg ~> address) =<< call unpack buf 0
  store (msg ~> ver) =<< call unpack buf 2
  store (msg ~> memory_vect_type) =<< call unpack buf 3
  arrayUnpack buf 4 (msg ~> value)

