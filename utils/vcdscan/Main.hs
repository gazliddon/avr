module Main where

import System.Environment
import Control.Applicative 
import Data.Bits
import Data.List
import Text.Printf

import Analyse
import AttoParser
import qualified Data.ByteString as B

hSyncDurationTarget = 76 * 50
vSyncDurationTarget = 635 * 50  * 2 

getPerc :: (Integral a) => a -> a -> Float
getPerc a b = (fromIntegral a / fromIntegral b) * 100 

toStr target actual = printf "%%%f (%d/%d)" (getPerc target actual) (actual) (target)

onFunc g f a b = f a `g` f b 
onEq = onFunc (==)
groupAnalysisStr target xs = (printf "%d samples : " (length xs)) ++ (toStr target . plDuration . head) xs   
genAnalysis target =  unlines . map (groupAnalysisStr target) . groupBy (onEq plDuration) 

inRange min dur val = (val >= min) && (val < (min + dur))
inRangeOnly' start duration = filter (inRange start duration . evTime) 

main = do
  (f:_) <- getArgs
  txt <- B.readFile f
  let vfile = parseVCDFIle txt
  let coms = vfEvents vfile 
  putStrLn "Hysnc"
  putStrLn "-----"
  putStrLn $ genAnalysis hSyncDurationTarget . hSyncDurations  $ coms

  putStrLn "Vsync"
  putStrLn "-----"
  putStrLn $ genAnalysis vSyncDurationTarget . vSyncDurations  $ coms
  putStrLn $ unlines . map show . vSyncDurations $ coms
  
  let (f0:f1:_) = vSyncDurations $ coms
  let start = plStart f0
  let duration = plStart f1 - plStart f0
  putStrLn $ "Frame start " ++ show start
  putStrLn $ "Frame duration " ++ show duration
  putStrLn $ show f0
  putStrLn $ show f1
  
  let frEvents =  inRangeOnly' start duration $ coms
  putStrLn "in range and events only"
  putStrLn . show  $ length frEvents
  putStrLn "hysncs from from that"
  putStrLn $ (show . length . hSyncDurations) frEvents



