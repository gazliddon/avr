{-# LANGUAGE OverloadedStrings #-}
module Main where

-- import qualified Data.ByteString as B
import Data.Word( Word8  )
import qualified Data.ByteString as B
import qualified Data.ByteString.Char8 as BC8
import Control.Applicative
import Data.Bits
import Data.List
import Data.Char 
import Numeric

import Opts
import ScrChrs

main = do
  opts <-  getOpts
  print opts
  pngBin <- B.readFile . head . files $ opts
  B.writeFile (out opts) $ BC8.pack . mkAsm . mkScreen . getDecoded $ pngBin
  putStrLn $ "Written " ++ (out opts) 

globVar align label = unlines [".align " ++ show align, ".global " ++ label, label ++ ":"]

toBytes :: [Int] -> String
toBytes =  (++) ".byte " . concat . intersperse "," . map show 

pbin a = (showIntAtBase 2 intToDigit a) ""
pcol = pbin . col2pack

mkAsm (Screen w h scr, ChrSet chars) = unlines $ allStrs where
  allStrs = [ ".section .data"
            , globVar 8 "screen"
            , toBytes [w,h]
            , toBytes scr
            , globVar 8 "characters"
            , toBytes $ charSetToBytes chars ]

colToBits :: Int -> Int -> Int
colToBits shift = flip shiftR (6 - shift) . (.&.) 0xc0

col2pack :: [Int] -> Int
col2pack [r,g,b] = foldl (\p (c,pos) -> p + colToBits pos c) 0 [(r,4),(g,2), (b,0)]

toTriplets [] = []
toTriplets (a:b:c:xs) = [a,b,c] : toTriplets xs

charToBytes :: Chr -> [Int]
charToBytes (Chr xs) = map col2pack $ toTriplets $ map fromIntegral xs 

charSetToBytes :: [Chr] -> [Int]
charSetToBytes cset = concatMap charToBytes cset


