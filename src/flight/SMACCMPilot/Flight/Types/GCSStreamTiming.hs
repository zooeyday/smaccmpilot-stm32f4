{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE QuasiQuotes #-}

{-# OPTIONS_GHC -fno-warn-orphans #-}

module SMACCMPilot.Flight.Types.GCSStreamTiming where

import Data.Maybe

import Ivory.Language
import Ivory.Stdlib

import SMACCMPilot.Flight.Types.GCSStreamStruct

--------------------------------------------------------------------------------

gcsStreamTimingTypeModule :: Module
gcsStreamTimingTypeModule = package "gcsstream_timing" $ do
  defStruct (Proxy :: Proxy "gcsstream_data")
  defStruct (Proxy :: Proxy "gcsstream_timing")
  defStruct (Proxy :: Proxy "gcsstream_schedule")

[ivory|

-- Schedule: represents next time for computation.
struct gcsstream_schedule
  { heartbeat_sched           :: Stored Uint32
  ; servo_output_raw_sched    :: Stored Uint32
  ; attitude_sched            :: Stored Uint32
  ; gps_raw_int_sched         :: Stored Uint32
  ; vfr_hud_sched             :: Stored Uint32
  ; global_position_int_sched :: Stored Uint32
  ; params_sched              :: Stored Uint32
  ; radio_sched               :: Stored Uint32
  }

-- Params: fixed until updated by the GCS user.
struct gcsstream_timing
  { heartbeat           :: Struct "gcsstream_data"
  ; servo_output_raw    :: Struct "gcsstream_data"
  ; attitude            :: Struct "gcsstream_data"
  ; gps_raw_int         :: Struct "gcsstream_data"
  ; vfr_hud             :: Struct "gcsstream_data"
  ; global_position_int :: Struct "gcsstream_data"
  ; params              :: Struct "gcsstream_data"
  ; radio               :: Struct "gcsstream_data"
  }

|]

--------------------------------------------------------------------------------

type GcsTimingLabel = Label "gcsstream_timing" (Struct "gcsstream_data")


-- Make sure to change these if you add new labels.
allTimingLabels :: [GcsTimingLabel]
allTimingLabels =
  [ heartbeat, servo_output_raw, attitude, gps_raw_int
  , vfr_hud, global_position_int, params, radio ]

allSchedLabels :: [Label "gcsstream_schedule" (Stored Uint32)]
allSchedLabels =
  [ heartbeat_sched, servo_output_raw_sched, attitude_sched, gps_raw_int_sched
  , vfr_hud_sched, global_position_int_sched, params_sched, radio_sched ]

toSchedLabel :: GcsTimingLabel -> Label "gcsstream_schedule" (Stored Uint32)
toSchedLabel l
  | length allTimingLabels /= length allSchedLabels
  = error "Timing and schedule structs are out of synch in GCSStreamTiming.hs"
  | otherwise
  = fromMaybe err $ lookup l (zip allTimingLabels allSchedLabels)
  where err = error "Timing labels are incomplete."

--------------------------------------------------------------------------------
-- XXX might be worth being a newtype, but it's a bit overkill here.

isHardRealTime :: IBool -> IBool
isHardRealTime = id

hardRealTime :: IBool
hardRealTime = true

softRealTime :: IBool
softRealTime = false

--------------------------------------------------------------------------------

-- | Initializer.
mkTimingData :: Uint32 -> IBool -> Init (Struct "gcsstream_data")
mkTimingData per hardrt = istruct [ period .= ival per
                                  , hard_deadline .= ival rt
                                  ]
  where rt = isHardRealTime hardrt

-- | Message period.
getPeriod :: ( IvoryRef ref
             , IvoryExpr (ref s (Struct "gcsstream_timing"))
             , IvoryExpr (ref s (Struct "gcsstream_data"))
             , IvoryExpr (ref s (Stored Uint32))
             )
          => GcsTimingLabel
          -> ref s (Struct "gcsstream_timing")
          -> Ivory eff Uint32
getPeriod l ref = do
  let d = ref ~> l
  return =<< (d ~>* period)

-- | Update message period.
setPeriod :: GcsTimingLabel
          -> Ref s (Struct "gcsstream_timing")
          -> Uint32
          -> Ivory eff ()
setPeriod l ref per = store (ref ~> l ~> period) per

-- | Hard real-time or soft real-time?
getDeadline :: ( IvoryRef ref
               , IvoryExpr (ref s (Struct "gcsstream_timing"))
               , IvoryExpr (ref s (Struct "gcsstream_data"))
               , IvoryExpr (ref s (Stored IBool))
               )
          => GcsTimingLabel
          -> ref s (Struct "gcsstream_timing")
          -> Ivory eff IBool
getDeadline l ref = do
  let d = ref ~> l
  return =<< (d ~>* hard_deadline)

setDeadline :: GcsTimingLabel
            -> Ref s (Struct "gcsstream_timing")
            -> IBool
            -> Ivory eff ()
setDeadline l ref v = do
  let d = ref ~> l
  store (d ~> hard_deadline) v
--------------------------------------------------------------------------------
