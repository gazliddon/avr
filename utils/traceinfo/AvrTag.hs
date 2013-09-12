module AvrTag where
import Text.Printf

data AvrData  = AvrString String String
              | AvrLong String Int
              | AvrNothing String
              | AvrSymbol Int String deriving Show

strLen a = length a + 1
header val id = [ ".byte " ++ id
                , ".byte " ++ show (size val) ]

size (AvrString id val) = strLen val
size (AvrLong _ _) = 4
size (AvrNothing _ ) = 0
size (AvrSymbol mask name) = strLen name + 2 + 1

source val@(AvrString id str) = header val id ++ [ ".asciz " ++ show str  ]
source val@(AvrLong id long) = header val id ++ [ ".long " ++ show long  ]
source val@(AvrNothing id) = header val id
source val@(AvrSymbol mask str) =
  header val "AVR_MMCU_TAG_VCD_TRACE" ++ [ ".byte " ++ show mask
                                         , ".word " ++ str
                                         , ".asciz " ++ show str ]

