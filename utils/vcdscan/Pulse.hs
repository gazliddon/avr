module Pulse where

import VCDVal

data Pulse = Pulse { pulStart :: Int
                   , pulDuration :: Int
                   , plVCDStart :: VCDVal
                   , plVCDEnd :: VCDVal } deriving (Show)

mkPulse ::  VCDVal -> VCDVal -> Pulse
mkPulse vc1 vc2 = Pulse { pulStart = evTime vc1
                        , pulDuration = (evTime vc2 - evTime vc1) - 1
                        , plVCDStart = vc1
                        , plVCDEnd = vc2 }

