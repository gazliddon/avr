
module VCDVal where

data VCDVal = Command !String !String
            | TimeScale !Int 
            | Var   { vrBits :: !Int,  vrSymbol :: !String, vrName :: !String }
            | Event { evTime :: !Int,  evMask :: !Int,      evSymbol :: !String }
            | Eof deriving (Eq, Show)


isCommand :: VCDVal -> Bool
isCommand Command{} = True
isCommand _         = False

isVar :: VCDVal -> Bool
isVar Var{} = True
isVar _     = False

isEvent :: VCDVal -> Bool
isEvent Event{} = True
isEvent _       = False

duration :: VCDVal -> VCDVal -> Int
duration a b = evTime b - evTime a


