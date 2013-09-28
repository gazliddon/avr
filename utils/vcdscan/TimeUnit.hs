module TimeUnit ( TimeUnit,
                  tuName, tuHz, tuSymbol,
                  findTimeTypeFromSymbol,

                  getString,
                  getBestString,

                  seconds, milliSeconds,
                  microSeconds, nanoSeconds ) where

import Data.List
import Data.Function
import Numeric

-- TODO : put in global utils

getOrderOfMagnitude :: Double -> Int
getOrderOfMagnitude a
  | signum a == 0 = 0
  | otherwise = floor . logBase 10 $ a  

---

data TimeUnit = TimeUnit {tuSymbol :: String, tuName :: String, tuHz :: Double} deriving Show

secsToUnit :: TimeUnit -> Double -> Double
secsToUnit t val = val / tuHz t

seconds :: TimeUnit
seconds =  TimeUnit "s"  "seconds"        1

milliSeconds :: TimeUnit
milliSeconds = TimeUnit "ms" "milliseconds" ( 1 / 1000)

microSeconds :: TimeUnit
microSeconds = TimeUnit "us" "microseconds" ( 1 / 1000 / 1000)

nanoSeconds :: TimeUnit
nanoSeconds =  TimeUnit "ns" "nanoseconds"  ( 1 / 1000 / 1000 / 1000)

allTimeUnits = [ seconds,
                 milliSeconds,
                 microSeconds,
                 nanoSeconds ]

findOnKey xs k val = [x |  x <- xs, k x == val ]
retFirstFunc [] = Nothing
retFirstFunc x = Just . head $ x
findInTimeUnits k val = retFirstFunc $ findOnKey allTimeUnits k val

findTimeTypeFromSymbol  = findInTimeUnits tuSymbol 

dist val t = getOrderOfMagnitude . secsToUnit t $ val 
getSorted val = filter ( (>= 0) . dist val ) $ sortBy (compare `on` dist val) allTimeUnits

findBestTimeUnit val = head (getSorted val)

getString t val = showFFloat (Just 2) (val / tuHz t) $ tuSymbol t
getBestString val = getString (findBestTimeUnit val) val

