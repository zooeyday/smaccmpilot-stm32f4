{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE MultiParamTypeClasses #-}

-- Autogenerated Mavlink v1.0 implementation: see smavgen_ivory.py

module SMACCMPilot.Mavlink.Messages.SetGpsGlobalOrigin where

import SMACCMPilot.Mavlink.Pack
import SMACCMPilot.Mavlink.Unpack
import SMACCMPilot.Mavlink.Send
import qualified SMACCMPilot.Communications as Comm

import Ivory.Language
import Ivory.Stdlib

setGpsGlobalOriginMsgId :: Uint8
setGpsGlobalOriginMsgId = 48

setGpsGlobalOriginCrcExtra :: Uint8
setGpsGlobalOriginCrcExtra = 41

setGpsGlobalOriginModule :: Module
setGpsGlobalOriginModule = package "mavlink_set_gps_global_origin_msg" $ do
  depend packModule
  depend mavlinkSendModule
  incl mkSetGpsGlobalOriginSender
  incl setGpsGlobalOriginUnpack
  defStruct (Proxy :: Proxy "set_gps_global_origin_msg")

[ivory|
struct set_gps_global_origin_msg
  { latitude :: Stored Sint32
  ; longitude :: Stored Sint32
  ; altitude :: Stored Sint32
  ; target_system :: Stored Uint8
  }
|]

mkSetGpsGlobalOriginSender ::
  Def ('[ ConstRef s0 (Struct "set_gps_global_origin_msg")
        , Ref s1 (Stored Uint8) -- seqNum
        , Ref s1 Comm.MAVLinkArray -- tx buffer
        ] :-> ())
mkSetGpsGlobalOriginSender =
  proc "mavlink_set_gps_global_origin_msg_send"
  $ \msg seqNum sendArr -> body
  $ do
  arr <- local (iarray [] :: Init (Array 13 (Stored Uint8)))
  let buf = toCArray arr
  call_ pack buf 0 =<< deref (msg ~> latitude)
  call_ pack buf 4 =<< deref (msg ~> longitude)
  call_ pack buf 8 =<< deref (msg ~> altitude)
  call_ pack buf 12 =<< deref (msg ~> target_system)
  -- 6: header len, 2: CRC len
  let usedLen = 6 + 13 + 2 :: Integer
  let sendArrLen = arrayLen sendArr
  if sendArrLen < usedLen
    then error "setGpsGlobalOrigin payload of length 13 is too large!"
    else do -- Copy, leaving room for the payload
            arrCopy sendArr arr 6
            call_ mavlinkSendWithWriter
                    setGpsGlobalOriginMsgId
                    setGpsGlobalOriginCrcExtra
                    13
                    seqNum
                    sendArr

instance MavlinkUnpackableMsg "set_gps_global_origin_msg" where
    unpackMsg = ( setGpsGlobalOriginUnpack , setGpsGlobalOriginMsgId )

setGpsGlobalOriginUnpack :: Def ('[ Ref s1 (Struct "set_gps_global_origin_msg")
                             , ConstRef s2 (CArray (Stored Uint8))
                             ] :-> () )
setGpsGlobalOriginUnpack = proc "mavlink_set_gps_global_origin_unpack" $ \ msg buf -> body $ do
  store (msg ~> latitude) =<< call unpack buf 0
  store (msg ~> longitude) =<< call unpack buf 4
  store (msg ~> altitude) =<< call unpack buf 8
  store (msg ~> target_system) =<< call unpack buf 12

