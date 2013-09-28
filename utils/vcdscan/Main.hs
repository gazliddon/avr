module Main where

import System.Environment
import Control.Applicative 
import Data.Bits
import Data.List
import Text.Printf

import TimeUnit
import VCDVal
import VCDParse
import Analyse
import Pulse

hSyncDurationTarget = 76 * 50
hLineDurationTarget = 635 * 50

getPerc :: (Integral a) => a -> a -> Float
getPerc a b = (fromIntegral a / fromIntegral b) * 100 

toStr target actual = printf "%%%f (%d/%d)" (getPerc target actual) (actual) (target)

onFunc g f a b = f a `g` f b 
onEq = onFunc (==)
groupAnalysisStr target xs = (printf "%d samples : " (length xs)) ++ (toStr target . pulDuration . head) xs   
genAnalysis target =  unlines . map (groupAnalysisStr target) . groupBy (onEq pulDuration) 

main = do
  (f:_) <- getArgs
  coms <- getCommands <$> readFile f
  putStrLn "Hysnc"
  putStrLn "-----"
  putStrLn $ genAnalysis hSyncDurationTarget . hSyncDurations  $ coms

