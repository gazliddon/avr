module VCDVal where

data VCDVal = Command String String
            | TimeScale Int 
            | Var   { vrBits :: Int,  vrSymbol :: String, vrName :: String }
            | Event { evTime :: Int,  evMask :: Int,      evSymbol :: String }
            | Eof deriving (Eq, Show)

isCommand Command{} = True
isCommand _         = False

isVar Var{} = True
isVar _     = False

isEvent Event{} = True
isEvent _       = False

findVars name xs = filter (\x -> (==) name (vrName x) ) $ filter isVar xs
findEvents sym xs = filter (\x -> (==) sym (evSymbol x)) $ filter isEvent xs

findEventsByVarName name xs = 
 let
   vars = findVars name xs
   ret [] = []
   ret (v:_) = findEvents (vrSymbol v) xs
 in
   ret vars


