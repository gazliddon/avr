module Avr where

import Data.List (intercalate, sortBy)
import Text.Printf
import qualified YamlToTrace as Y2T

avrSection = ".mmcu"

defCommentCol = 60
defIndent = 4

defArrayToAsmLines = arrayToAsmLines defIndent
defToAsmLine = toAsmLine defIndent
defAlignComments = alignToColumn defCommentCol
defComment str = printf "%s ;; %s" $ defAlignComments str

toAsmLine = indent
arrayToAsmLines indentAmount array = intercalate "\n" $ map (toAsmLine indentAmount) array

ret = "\n"
indent amount str = replicate amount ' ' ++ str 
alignToColumn v str = str ++ replicate (max 0 (v - length str)) ' '

asmLong = printf ".long %d"
asmPtr = printf ".word %s"
asmAsciiZ = printf ".asciz \"%s\""
asmByte  = printf ".byte %d"
asmByteEqu = printf ".byte %s"

strLen = ((+1) .length )

-- AVR Tag Type Class  --
class AvrTag a where
  len :: a -> Int
  tag :: a -> String
  getTagString :: a -> String
  getTagString a = defArrayToAsmLines [
          defComment (asmByteEqu (tag a)) "Tag value"
        , defComment (asmByte (len a)) "Record length"
        ] ++ ret
  getSource :: a -> String

  header :: a -> String -> [String] -> String
  header a comment srcs =
    ";;" ++ intercalate ret ([ comment, getTagString a] ++ srcs)


-- AVR VCD File --
data AvrVCDFile = AvrVCDFile { vcdFile :: AvrString, vcdPeriod :: AvrLong }

mkAvrVCDFile file period =
  AvrVCDFile { vcdFile = AvrString "AVR_MMCU_TAG_VCD_FILENAME" file
             , vcdPeriod = AvrLong "AVR_MMCU_TAG_VCD_PERIOD"   period }

instance AvrTag AvrVCDFile where
  len a = len (vcdFile a) + len (vcdPeriod a)
  tag a = ""
  getSource a = getSource (vcdFile a) ++ ret ++ getSource (vcdPeriod a)


-- AVR String --
data AvrString = AvrString { stringTag :: String, stringStr :: String  }


instance AvrTag AvrString where
   len a = (strLen . stringStr) a
   tag = stringTag
   getSource a = getTagString a ++ ret ++ defArrayToAsmLines [ asmAsciiZ (stringStr a) ]

-- AVR Long --
data AvrLong = AvrLong { longTag :: String, longVal :: Int  }

instance AvrTag AvrLong where
   len a = 4
   tag = longTag
   getSource a = getTagString a ++ ret ++ defArrayToAsmLines [ asmLong (longVal a) ]


-- AVR Symbol --
data AvrSymbol = AvrSymbol { symbolName :: String, symbolMask :: Int } deriving Show

instance AvrTag AvrSymbol where
  tag a = "AVR_MMCU_TAG_VCD_TRACE"
  len a = strLen (symbolName a) + 2 + 1 -- strlen + mask + word ptr to symbol
  getSource a =
    let (sym, mask) = ( symbolName a, symbolMask a )
        src =  defArrayToAsmLines [ defComment (asmByte mask) "Bit mask"
                                  , defComment (asmPtr sym) "Pointer to thing to trace"
                                  , asmAsciiZ sym ]
    in header a "AVR trace records" [src]


-- AVR CPU --
data AvrCpu = AvrCpu { cpuName :: String, cpuFreq :: Int } deriving Show

instance AvrTag AvrCpu where
  tag a = "AVR_MMCU_TAG"
  len a = 0
  getSource a = header a "AVR CPU record" [ getSource $ AvrString "AVR_MMCU_TAG_NAME" $ cpuName a
                                          , getSource $ AvrLong "AVR_MMCU_TAG_FREQUENCY" $ cpuFreq a]

-- AVR Trace List --
section = defToAsmLine ".section " ++ show avrSection
mmcu = "mmcu_:" 
addRet a = a ++ ret

avrTracesHeader a text arr =
  concatMap addRet [ section
                   , mmcu
                   , header a text arr ] 

data AvrTraces = AvrTraces { trTraces :: [AvrSymbol]
                           , trCpuType :: String
                           , trCpuFreq :: Int } deriving Show

instance AvrTag AvrTraces where
  len a = 0
  tag a = "AVR_MMCU_TAG_VCD_TRACE"
  getSource a = avrTracesHeader a "All My Info" [ concatMap getSource $ trTraces a
                                                , getSource $ AvrCpu (trCpuType a) (trCpuFreq a) ]

traceFromRecord :: Y2T.TraceRecord -> String
traceFromRecord tr =
  getSource $ Avr.AvrTraces { trTraces =  map (`AvrSymbol` 0) $ Y2T.vars tr
                            , trCpuType = Y2T.cpuType tr
                            , trCpuFreq = Y2T.cpuFreq tr}

ttest = traceFromRecord $ Y2T.TraceRecord { Y2T.cpuType = "atmega88"
                        , Y2T.cpuFreq = 20000000
                        , Y2T.vars = ["DDRB","TCCR0B"]
                        , Y2T.vcdFile = "./trace.vcd"
                        , Y2T.vcdPeriod = 1 }


