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

duration a b = evTime b - evTime a


