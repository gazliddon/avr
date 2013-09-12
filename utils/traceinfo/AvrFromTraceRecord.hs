module AvrFromTraceRecord where
import qualified YamlToTrace as Y2T
import Text.Printf
import AvrTag

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
