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

minitest = do
  coms <- getCommands <$> readFile "test.vcd"
  putStrLn $ "read " ++ show (length coms)
  let v = testAnalyse coms
  putStrLn $  v

main = do
  putStrLn "todo"





