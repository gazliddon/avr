module TimeUnit ( TimeUnit,
                  findTimeTypeFromSymbol,
                  findTimeTypeFromName,
                  allTimeUnits,
                  getString,
                  getBestString,

                  seconds, milliSeconds,
                  microSeconds, nanoSeconds ) where

import Data.List
import Data.Function

data TimeUnit = TimeUnit {symbol :: String, name :: String, hz :: Double} deriving Show

seconds =      TimeUnit "s"  "seconds"        1
milliSeconds = TimeUnit "ms" "milliseconds" ( 1 / 1000)
microSeconds = TimeUnit "us" "microseconds" ( 1 / 1000 / 1000)
nanoSeconds =  TimeUnit "ns" "nanoseconds"  ( 1 / 1000 / 1000 / 1000)

allTimeUnits = [ seconds,
                 milliSeconds,
                 microSeconds,
                 nanoSeconds ]

findOnKey xs k val = [x |  x <- xs, (k x) == val ]
retFirstFunc [] = Nothing
retFirstFunc x = Just . head $ x

findInTimeUnits k val = retFirstFunc $ (findOnKey allTimeUnits) k val

findTimeTypeFromSymbol str = findInTimeUnits symbol str
findTimeTypeFromName str = findInTimeUnits name str

secsToUnit t val = val / hz t

dist val t = 1 - (abs $ (hz t) -  (secsToUnit t val)) 

getSorted val = reverse $ sortBy (compare `on` (dist val)) allTimeUnits  

adjFunc t = abs $ 1 - t

getSortedKey val = map (\x -> ( symbol x, (secsToUnit x val) , adjFunc (secsToUnit x val)  )) $ getSorted val

findBestTimeUnit val = head (getSorted val)

getString t val = show (val / hz t) ++ (symbol t)
getBestString val = getString (findBestTimeUnit val) val

