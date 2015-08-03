{-# LANGUAGE DataKinds #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE TypeFamilies #-}
{-# OPTIONS_GHC -fno-warn-orphans #-}

module SMACCMPilot.Flight.Sensors.GPS (uartUbloxGPSTower) where

import Ivory.BSP.STM32.Driver.UART
import Ivory.BSP.STM32.Driver.UART.DMA
import Ivory.Language
import Ivory.Tower
import Ivory.Tower.HAL.Bus.Interface
import SMACCMPilot.Flight.Platform
import SMACCMPilot.Hardware.GPS.UBlox

[ivory| string struct UnusedString 1 |]
[ivory| string struct GPSString 128 |]

uartUbloxGPSTower :: (e -> FlightPlatform)
                  -> ChanInput (Struct "position")
                  -> Tower e ()
uartUbloxGPSTower tofp ostream = do
  let types = package "gps_common" $ do
        defStringType (Proxy :: Proxy UnusedString)
        defStringType (Proxy :: Proxy GPSString)
  towerModule types
  towerDepends types
  fp <- fmap tofp getEnv
  let uart = fp_gps fp
  let tocc = fp_clockconfig . tofp
  gps <- case uart_periph uart of
    Left u -> uartTower tocc u (uart_pins uart) 38400
    Right dmauart -> dmaUARTTower tocc dmauart (uart_pins uart) 38400 (Proxy :: Proxy GPSString)
  -- we ignore the transmit channel, but we're forced to provide a buffer type for it
  let _gpso = fst gps :: BackpressureTransmit UnusedString (Stored IBool)
  ubloxGPSTower (snd gps) ostream
