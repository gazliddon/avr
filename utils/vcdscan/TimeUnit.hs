module TimeUnit ( TimeUnit,
                  findTimeTypeFromSymbol,
                  allTimeUnits,

                  getString,
                  getBestString,

                  seconds, milliSeconds,
                  microSeconds, nanoSeconds ) where

import Data.List
import Data.Function
import Numeric

-- Could probably go in some generic utils
getOrderOfMagnitude 0 = 0
getOrderOfMagnitude v  = floor . logBase 10 $ v  

data TimeUnit = TimeUnit {symbol :: String, name :: String, hz :: Double} deriving Show

secsToUnit t val = val / hz t

seconds =      TimeUnit "s"  "seconds"        1
milliSeconds = TimeUnit "ms" "milliseconds" ( 1 / 1000)
microSeconds = TimeUnit "us" "microseconds" ( 1 / 1000 / 1000)
nanoSeconds =  TimeUnit "ns" "nanoseconds"  ( 1 / 1000 / 1000 / 1000)

allTimeUnits = [ seconds,
                 milliSeconds,
                 microSeconds,
                 nanoSeconds ]

findOnKey xs k val = [x |  x <- xs, k x == val ]
retFirstFunc [] = Nothing
retFirstFunc x = Just . head $ x
findInTimeUnits k val = retFirstFunc $ findOnKey allTimeUnits k val

findTimeTypeFromSymbol  = findInTimeUnits symbol 

dist val t = (getOrderOfMagnitude . secsToUnit t) val 
getSorted val = filter ( (>= 0) . dist val ) $ sortBy (compare `on` dist val) allTimeUnits

findBestTimeUnit val = head (getSorted val)

getString t val = showFFloat (Just 2) (val / hz t) $ symbol t
getBestString val = getString (findBestTimeUnit val) val

