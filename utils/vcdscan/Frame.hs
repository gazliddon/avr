module Frame where

import VCDVal
import Pulse
import Analyse

data Pixel = Pixel Int deriving (Show)

data Line = Line { hSync   :: Pulse
		 , pixels  :: [Pixel] } deriving (Show)

data Frame = Frame { frLines   :: [Line]
                   } deriving (Show)

makeLine :: [VCDVal] -> Line
makeLine evs = Line { hSync = head . hSyncDurations $ evs
                    , pixels = map (Pixel . evMask) . findEventsByVarName "mem_PORTB" $ evs } 

makeFrame :: [VCDVal] -> Frame
makeFrame evs = Frame { frLines = myLines
                       }
  where
    myLines = map (\a -> Line a [Pixel 100, Pixel 100]) . hSyncDurations $ evs
    
