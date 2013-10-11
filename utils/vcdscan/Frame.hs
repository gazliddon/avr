{-# LANGUAGE OverloadedStrings #-}
module Frame where

import Analyse
import AttoParser
import Ppm
import Data.Bits

data Pixel = Pixel { pxCycle :: Int
                   , pxCol   :: Int} deriving (Show)

data Line = Line { lnSync   :: Pulse
		 , lnPixels  :: [Pixel] } deriving (Show)

data Frame = Frame { frLines   :: [Line]
                   , frMaxLineWidth :: Int} deriving (Show)

makeLine :: Pulse -> [Event] -> Line
makeLine hs evs = Line { lnSync = hs, lnPixels = pixels }
  where
    mkPixel e = Pixel (quot (evTime e - plStart hs) 50) (evMask e)
    pixels = map mkPixel . filter ((==) "mem_PORTD" . evSymbol) $ evs 

makeFrame :: [Event] -> Frame
makeFrame evs = Frame { frLines = myLines, frMaxLineWidth = maxLineDuration }
  where
    hsd = lineDurations evs
    maxLineDuration = quot (foldl (\a b -> max (plDuration b) a) 0 hsd) 50
    myLines = map (\a -> makeLine a . inRangeOnly (plStart a) (plDuration a) $ evs) hsd

getDims frm = (frMaxLineWidth frm, length . frLines $ frm)

toPixel px = map (\a -> quot a 1) [r,g,b]
  where
    p = (pxCol px)
    r = (p .&. 3) * 0x40 
    g = ((quot p 4 ) .&. 3) * 0x40
    b = ((quot p 16) .&. 3) * 0x40

-- Convert stream of events into an array of pixels
emit [] _ _ = [] 
emit (c:cs) currentCol [] = currentCol : emit cs currentCol [] 
emit (c:cs) currentCol allp@(p:ps)
  | pxCycle p <= c = (toPixel p) : emit cs (toPixel p) ps
  | otherwise = currentCol : emit cs currentCol allp

createPpm frm = makePpm image
  where
    (w,h) = getDims frm
    lineToColor = emit [0 .. (w-1)] [255,0,255] . lnPixels
    image = (w, h, concatMap lineToColor . frLines $ frm)

