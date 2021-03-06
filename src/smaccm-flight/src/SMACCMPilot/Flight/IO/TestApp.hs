

module SMACCMPilot.Flight.IO.TestApp
  ( app
  ) where

import Ivory.Language
import Ivory.Tower
import Ivory.Stdlib

import SMACCMPilot.Flight.Platform
import SMACCMPilot.Flight.Datalink
import SMACCMPilot.Flight.Datalink.UART
import SMACCMPilot.Flight.Datalink.ControllableVehicle
import SMACCMPilot.Flight.IO

import qualified SMACCMPilot.Comm.Ivory.Types.ArmingMode      as A
import qualified SMACCMPilot.Comm.Ivory.Types.ControlLaw      as CL
import qualified SMACCMPilot.Comm.Ivory.Types.ControlSource   as CS
import qualified SMACCMPilot.Comm.Ivory.Types.Tristate        as T
import qualified SMACCMPilot.Comm.Ivory.Types.TimeMicros      as T
import qualified SMACCMPilot.Comm.Ivory.Types.UserInput       as UI ()
import qualified SMACCMPilot.Comm.Ivory.Types.UserInputResult as UIR

import SMACCMPilot.Comm.Tower.Attr
import SMACCMPilot.Comm.Tower.Interface.ControllableVehicle

app :: (e -> FlightPlatform)
    -> Tower e ()
app tofp = do

  cvapi@(attrs, _streams) <- controllableVehicleAPI

  fp  <- fmap tofp getEnv
  mon <- datalinkTower tofp cvapi
    (uartDatalink (fp_clockconfig . tofp) (fp_telem fp) 115200)
  monitor "uart_dma" mon

  -- Don't hook anything up to outputs!
  (_, output_cl) <- channel
  (_, output_motors) <- channel

  -- Inputs generated by flightIOTower will be forwarded:
  ui <- channel
  cm <- channel
  am <- channel

  flightIOTower tofp attrs (fst ui) (fst cm) (fst am) output_cl output_motors

  -- Connect those inputs to attrs:
  monitor "forward_flightIOTower" $ do
    handler (snd ui) "ui" $ do
      e <- attrEmitter (userInput attrs)
      callback $ \v -> do
        now <- fmap (T.TimeMicros . toIMicroseconds) getTime
        o <- local (istruct [ UIR.time .= ival now
                            , UIR.source .= ival CS.ppm ])
        refCopy (o ~> UIR.ui) v
        emit e (constRef o)

    a <- stateInit "armed_mode" (ival A.safe)
    handler (snd am) "arming_mode_input" $ do
      callbackV $ \am_req -> do
        when (am_req ==? T.negative) (store a A.safe)
        when (am_req ==? T.positive) (store a A.armed)

    handler (snd cm) "control_modes_input" $ do
      e <- attrEmitter (controlLaw attrs)
      callback $ \cm_req -> do
        l <- local izero
        refCopy (l ~> CL.control_modes) cm_req
        refCopy (l ~> CL.arming_mode) a
        emit e (constRef l)
