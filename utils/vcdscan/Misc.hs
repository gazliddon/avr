module Misc where

searchForPatterns :: [a -> Bool] -> [a] -> [[a]]
searchForPatterns pat xs = filter ((==) 0 . length ) $ recur xs
  where
    recur xxs
      | null xxs  = []
      | length pat > length xxs = [] 
      | otherwise = thisMatch : recur (tail xxs)
      where
        matches =  foldl (\acc (f,a) -> (&&) acc (f a)) True $ zip pat xxs 
        thisMatch
           | matches = take (length pat) xxs
           | otherwise = []

