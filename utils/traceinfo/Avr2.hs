module Avr2 where
import qualified YamlToTrace as Y2T
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

fromTraceRec rec =
        [ AvrNothing "AVR_MMCU_TAG"
        , AvrString "AVR_MMCU_TAG_NAME"      $ Y2T.cpuType rec
        , AvrLong   "AVR_MMCU_TAG_FREQUENCY" $ Y2T.cpuFreq rec
        , AvrString "AVR_MMCU_TAG_VCD_FILENAME" $ Y2T.vcdFile rec
        , AvrLong "AVR_MMCU_TAG_VCD_PERIOD" $ Y2T.vcdPeriod rec]
        ++ map (AvrSymbol 0) (Y2T.vars rec)

sourcHeader = sourceBlock [".section \".mmcu\"", ".global _mmcu"] ++ "_mmcu:" ++ "\n"
sourceBlock a = concatMap (printf "\t%s\n") a ++ "\n" 
makeSourceFromRec rec = (++) sourcHeader $ concatMap (sourceBlock . source) $ fromTraceRec rec

-- Test Code
y2Record = Y2T.TraceRecord { Y2T.cpuType = "atmega88"
                        , Y2T.cpuFreq = 20000000
                        , Y2T.vars = ["DDRB","TCCR0B"]
                        , Y2T.vcdFile = "./trace.vcd"
                        , Y2T.vcdPeriod = 1 }

test = makeSourceFromRec y2Record
