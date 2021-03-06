-- Crappy stuff to write out a PPM file, the easiest image 
-- file format in the world :)
module Ppm where

type Color = [Int]
type Image = (Int, Int, [Color])

-- Join a list of strings using a separator string.
join :: String -> [String] -> String
join _ [x]    = x
join sep (x:xs) = x ++ sep ++ join sep xs

makePpm :: Image -> String
makePpm (width, height, im) = join "\n" line_list ++ "\n"   
    where line_list = ["P3", show width ++ " " ++ show height, "255"] ++ map (join " " . map show) im

