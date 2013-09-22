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

hSyncDurationTarget = 76 * 50
hLineDurationTarget = 634 * 50

getPerc a b = (fromIntegral a / fromIntegral b) * 100 
toStr target actual = show (getPerc actual target) ++ "%" ++ " (" ++ show actual ++ "/" ++ show target ++ ")"

toStr' target (key, size) = toStr target key

genAnalysis target xs = map toStr' $ map (\as@(a:_) -> (a, length as)) $ group xs

main = do
  (f:_) <- getArgs
  coms <- getCommands <$> readFile f
  let v = findTogglesDuration "mem_PORTB" 1 coms
  putStrLn "Hysnc"
  putStrLn "-----"
  putStrLn $ unlines . map (\(v,s) -> show s ++ " at " ++ toStr 3800 v) $ map ( \ as@(a:_) -> (a, length as) ) $ group v






