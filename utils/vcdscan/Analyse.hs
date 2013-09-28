module Analyse where

import Control.Applicative 
import Data.Bits
import Data.List

import TimeUnit
import VCDVal
import VCDParse
import Pulse

findIt name field f = filter (\a -> f a && name == field a) 

findVars name = findIt name vrName isVar
findEvents name = findIt name evSymbol isEvent

findEventsByVarName name xs = retFunc (findVars name xs)
  where
    retFunc [] = []
    retFunc (x:_) = findEvents (vrSymbol x) xs

togglesOnly mask  = dropWhile ((==) 0 . (.&.) mask . evMask) . uniquesOnly mask 
uniquesOnly mask = removeRuns (\a b -> (evMask a) .&. mask == (evMask b) .&. mask ) 
inRangeOnly start dur = filter ( \Event {evTime=t} -> t >= start && t <= start + dur)

findToggles name mask = togglesOnly mask . findEventsByVarName name

findTogglesDuration name mask  = map (\(a,b) -> mkPulse a b ) . toPairs . findToggles name mask 

-- Test Code
hSyncDurations = findTogglesDuration "mem_PORTB" 1
vSyncDurations = findTogglesDuration "mem_PORTB" 2

testAnalyse xs = unlines . map show  $ findTogglesDuration "mem_PORTB" 2 xs

test = do
  coms <- getCommands <$> readFile "test.vcd"
  let hs = findTogglesDuration  "mem_PORTB" 2 coms
  putStrLn .unlines . map show $ hs 

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


