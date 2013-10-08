{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}

-- | Take airdata messages from SMACCMPilot, encrypt them, and send them to the
-- datalink task.

module SMACCMPilot.Flight.Commsec.Encrypt where

import qualified SMACCMPilot.Flight.Commsec.Commsec   as CS
import qualified Commsec.CommsecOpts                  as O
import qualified SMACCMPilot.Communications           as Comm

import           Ivory.Tower
import           Ivory.Language

--------------------------------------------------------------------------------

encryptTask :: (SingI n0, SingI n1)
            => O.Options
            -> ChannelSink   n0 Comm.MAVLinkArray -- from GCS Tx
            -> ChannelSource n1 Comm.CommsecArray -- to datalink
            -> Task p ()
encryptTask opts rx tx = do
  emitter <- withChannelEmitter tx "encToHxSrc"

  -- Sets up commsec for both encryption and decryption.
  taskInit (CS.setupCommsec opts)

  onChannel rx "gcsTxToEnc" $ \mavStream -> do
    mav <- local (iarray [])
    refCopy mav mavStream

    pkg <- local (iarray [] :: Init Comm.CommsecArray)
    CS.copyToPkg (constRef mav) pkg
    CS.encrypt CS.uavCtx pkg
    emit_ emitter (constRef pkg)

  let m = CS.commsecModule opts
  taskModuleDef $ depend m
  withModule m



