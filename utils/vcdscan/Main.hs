module Main where

import System.Environment
import Control.Applicative 
import Data.Maybe
import Data.Bits

-- import ParsecHelper
import TimeUnit
import VCDVal
import VCDParse

-- Inline bitwise and
bitand = (.&.)
onlyMasked f mask xs = filter  (f . bitand mask . evMask) xs 
onlyOff mask xs = onlyMasked $ (==) 0
onlyOn mask xs = onlyMasked $ (/=) 0

{-
RLE a set of objects predicated on function f compare
if head of next is run and reprocess list
if head of next isn't run emit run information
if one elemeny in list emit run information
if no elements in list emit empty list
-}

runLengthEncode f xs = recur 0 f xs
  where recur _ _ [] = []
        recur _ _ [y] = [(1,y)]
        recur count f (y:ys)
          | f y (head ys) = recur (count+1) f (tail ys)
          | otherwise = (count, y) : recur 0 f ys

-- Wow, that's pretty terse, should chuck in utils
searchForOnOff xs = searchForPatterns [(/=) 0 . evMask, (==) 0 . evMask] xs

searchForPatterns :: [(a -> Bool)] -> [a] -> [[a]]
searchForPatterns pat xs = filter ((==) 0 . length ) $ recur pat xs
  where
    recur pat xxs
      | length xxs == 0 = []
      | length pat > length xxs = [] 
      | otherwise = [thisMatch] ++ recur pat (tail xxs)
      where
        matches =  foldl (\acc (f,a) -> (&&) acc (f a)) True $ zip pat xxs 
        thisMatch
           | matches = take (length pat) $ xxs
           | otherwise = []
      
arrayStr = unlines . map show

main = do
  text <- (head <$> getArgs) >>= readFile
  file <- head <$> getArgs
  test <- getCommands <$> readFile file
  let yeah = findEventsByVarName "mem_PORTB" test
  let wow = searchForOnOff yeah
  putStrLn . arrayStr $ yeah
  print wow
  
