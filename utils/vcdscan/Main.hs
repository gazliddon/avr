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
hLineDurationTarget = 635 * 50

getPerc a b = (fromIntegral a / fromIntegral b) * 100 
toStr target actual = show (getPerc actual target) ++ "%" ++ " (" ++ show actual ++ "/" ++ show target ++ ")"
genAnalysis target= unlines . map (\(v,s) -> show s ++ " at " ++ toStr target v) . map ( \ as@(a:_) -> (a, length as) ) . group

genAnalysis' name target symbol mask  = []


main = do
  (f:_) <- getArgs
  coms <- getCommands <$> readFile f
  putStrLn "Hysnc"
  putStrLn "-----"
  putStrLn . genAnalysis hSyncDurationTarget . findTogglesDuration "mem_PORTB" 1  $ coms






