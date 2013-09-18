module Main where

import System.Environment
import Control.Applicative 
import Data.Maybe
import Data.Bits
import Data.List
import Text.Printf
-- import ParsecHelper
import TimeUnit
import VCDVal
import VCDParse

-- Inline bitwise and
bitand = (.&.)
onlyMasked f mask xs = filter  (f . bitand mask . evMask) xs 
onlyOff mask xs = onlyMasked $ (==) 0
onlyOn mask xs = onlyMasked $ (/=) 0

dur a b = evTime b - evTime a
searchForOnOff xs = map (\(a:b:_) -> dur a b) $  groupBy (\a b -> evMask a /= 0 && evMask b == 0) xs
allOnes xs = filter ((/=) 0 . evMask)  xs 

betweenEvents xs
  | length xs < 2 = []
  | otherwise = map (\(a,b) -> dur a b) $ zip xs $ tail xs

data Analysis = Analysis {anHysncDurations :: [Int], anLineDurations :: [Int] }

hSyncDurationTarget = 76 * 50
hLineDurationTarget = 634 * 50

getPerc a b = (fromIntegral a / fromIntegral b) * 100 
toStr target actual = show (getPerc actual target) ++ "%" ++ " (" ++ show actual ++ "/" ++ show target ++ ")"

analyseDurations target = unlines . map (toStr target) 

main = do
  text <- (head <$> getArgs) >>= readFile
  file <- head <$> getArgs
  test <- getCommands <$> readFile file
  let syncChanges = findEventsByVarName "mem_PORTB" test
  
  putStrLn "Hysnc duration"
  putStrLn "--------------"
  putStrLn $ analyseDurations hSyncDurationTarget $ searchForOnOff syncChanges

  putStrLn ""
  putStrLn "Line Duration"
  putStrLn "-------------"
  putStrLn $ analyseDurations hLineDurationTarget $ betweenEvents $ allOnes syncChanges


