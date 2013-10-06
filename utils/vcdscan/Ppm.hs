-- Crappy stuff to write out a PPM file, the easiest image 
-- file format in the world :)
module Ppm where

type Color = [Integer]
type Image = (Integer, Integer, [Color])

-- Join a list of strings using a separator string.
join :: String -> [String] -> String
join _ [x]    = x
join sep (x:xs) = x ++ sep ++ join sep xs

makePpm :: Image -> String
makePpm (width, height, im) = join "\n" line_list ++ "\n"   
    where line_list = ["P3", show width ++ " " ++ show height, "255"] ++ map (join " " . map show) im

test0 = do
  let mkcol x = [x,x,x]
  let ppm = makePpm (16, 16, (map mkcol [0..255])) 
  writeFile "test0.ppm" ppm 
  
