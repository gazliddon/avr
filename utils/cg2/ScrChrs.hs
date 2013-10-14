module ScrChrs where

import Data.Word( Word8  )
import qualified Data.Vector.Storable as V 
import Codec.Picture
import Data.List 

getDecoded p = case decodePng p of
  Left err -> error err
  Right val -> val

getImage x@(ImageRGB8 img) = img


data Screen = Screen { scW   :: Int
                     , scH   :: Int
                     , scScr :: [Int] } deriving (Show)

data Chr = Chr [Word8] deriving (Show, Eq)
data ChrSet = ChrSet { chChrs :: [Chr] } 

instance Show ChrSet where
  show ChrSet{ chChrs = c} = "ChrSet : numChars = " ++ (show .length $ c)

addChr :: ChrSet -> Chr -> (Int, ChrSet)
addChr cset@ChrSet{chChrs = chrs} ch = case elemIndex ch chrs of
  Nothing -> (length chrs, ChrSet {chChrs= chrs ++ [ch]})
  Just a -> (a, cset )

grabChr img x y = Chr pixels 
  where
    widthInBytes = 3 * imageWidth img 
    pixels =  concatMap (\i -> V.toList . V.slice i 24 $ imageData img ) [x * 3 + widthInBytes * yy | yy <- [y..y+7]]

mkScreen :: DynamicImage -> (Screen, ChrSet)
mkScreen(ImageRGB8 img) = foldl foldFunc initRecord [ grabChr img (x*8) (y*8) | y <- [0.. h-1], x<-[0 .. w-1] ] 
  where
    w = quot (imageWidth  img) 8
    h = quot (imageHeight img) 8
    initRecord = (Screen w h [], ChrSet [])
    foldFunc ( Screen _ _ screen, charSetIn) chr = (Screen w h (screen ++ [characterNum]), charSetOut )
      where (characterNum, charSetOut) = addChr charSetIn chr


