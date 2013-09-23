module Analyse where

import Control.Applicative 
import Data.Bits
import Data.List

import TimeUnit
import VCDVal

findIt name field f xs = filter ((==) name . field) (filter f xs)

findVars name = findIt name vrName isVar
findEvents name = findIt name evSymbol isEvent

findEventsByVarName name xs = retFunc (findVars name xs)
  where
    retFunc [] = []
    retFunc (x:_) = findEvents (vrSymbol x) xs

findTogglesDuration name mask xs = map (\(a,b) -> (duration a b) -1 ) $ toPairs . findToggles name mask $ xs

findToggles name mask xs  = dropWhile ((==) 0 . (.&.) mask . evMask)
                          $ removeRuns (\a b -> (evMask a) .&. mask == (evMask b) .&. mask ) 
                          $ findEventsByVarName name xs 

-- Test Code

hSyncDurations xs = findTogglesDuration "mem_PORTB" 1
vSyncDurations xs = findTogglesDuration "mem_PORTB" 2

testAnalyse xs = unlines . map show  $ findTogglesDuration "mem_PORTB" 2 xs

-- Test Code


-- TODO : move to utils

toPairs [] = []
toPairs [a] = []
toPairs (a:b:abs) = (a,b) : (toPairs abs)

removeRuns f xs = recur xs
  where
    recur [] = []
    recur [a] = [a]
    recur (a:b:abs)
      | f a b = recur (b:abs) 
      | otherwise = a : recur (b : abs)

-- TODO


