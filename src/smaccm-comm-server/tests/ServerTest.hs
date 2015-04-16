
module Main where

import Ivory.Tower.Config
import Ivory.Tower.Compile
import Ivory.OS.FreeRTOS.Tower.STM32

import SMACCMPilot.Hardware.Tests.Platforms
import SMACCMPilot.Comm.Ivory.Server.TestApp (app)

main :: IO ()
main = towerCompile p (app id)
  where
  p topts = do
    cfg <- getConfig topts px4PlatformParser
    return $ stm32FreeRTOS px4platform_stm32config cfg
