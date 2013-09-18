module Misc where

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

