{-# LANGUAGE OverloadedStrings #-}
module Analyse where

import Control.Applicative 
import Data.Bits
import Data.List
import AttoParser
import qualified Data.ByteString as B

data Pulse = Pulse { plStart :: Int
                   , plDuration :: Int
                   , plEv0 :: Event 
                   , plEv1 :: Event } deriving (Show)

mkPulse ::  Event -> Event -> Pulse
mkPulse vc1 vc2 = Pulse { plStart = evTime vc1
                        , plDuration = (evTime vc2 - evTime vc1) 
                        , plEv0 = vc1
                        , plEv1 = vc2 }

uniquesOnly mask = removeRuns (\a b -> (evMask a) .&. mask == (evMask b) .&. mask ) 
togglesOnly mask  = dropWhile ((==) 0 . (.&.) mask . evMask) . uniquesOnly mask 
findToggles name mask = togglesOnly mask . filter ((==) name . evSymbol)
findTogglesDuration name mask  = map (\(a,b) -> mkPulse a b ) . toPairs . findToggles name mask 

-- Test Code
hSyncDurations = findTogglesDuration "mem_PORTB" 1
vSyncDurations = findTogglesDuration "mem_PORTB" 2

-- TODO : move to utils
toPairs [] = []
toPairs [a] = []
toPairs (a:b:abs) = (a,b) : toPairs abs

removeRuns f = recur
  where
    recur [] = []
    recur [a] = [a]
    recur (a:b:abs)
      | f a b = recur (a:abs) 
      | otherwise = a : recur (b : abs)

-- TODO


