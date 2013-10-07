{-# LANGUAGE OverloadedStrings #-}
module Main where

import System.Environment
import Control.Applicative 
import Data.Bits
import Data.List
import Text.Printf

import Analyse
import AttoParser
import Frame
import Ppm
import qualified Data.ByteString as B

getPerc :: (Integral a) => a -> a -> Float
getPerc a b = (fromIntegral a / fromIntegral b) * 100 

toStr target actual = printf "%%%f (%d/%d)" (getPerc target actual) (actual) (target)
onFunc g f a b = f a `g` f b 
onEq = onFunc (==)
groupAnalysisStr target xs = (printf "%d samples : " (length xs)) ++ (toStr target . plDuration . head) xs   
genAnalysis target =  unlines . map (groupAnalysisStr target) . groupBy (onEq plDuration) 

analyse name target xs =
  unlines [
    name,
    genAnalysis target  xs
  ]


hSyncDurationTarget = 76 * 50
vSyncDurationTarget = 635 * 50  * 2 

main = do
  (f:_) <- getArgs
  coms <- vfEvents .parseVCDFIle <$> B.readFile f

  let vsd = vSyncDurations coms
  let hsd = hSyncDurations coms
  
--  putStrLn $ analyse "Hsync" hSyncDurationTarget hsd 
--  putStrLn $ analyse "Vsync" vSyncDurationTarget vsd 
 
  let (f0:f1:_) = vsd
  let start = plStart f0
  let duration = plStart f1 - plStart f0
  
  let frEvents =  inRangeOnly start duration $ coms
  let frm = makeFrame frEvents
  print . getDims $ frm
  let ppm = createPpm frm
  writeFile "frm.ppm" ppm
  putStrLn "Written frm.ppm"
