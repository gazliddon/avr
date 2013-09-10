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
asmAsciiZ = printf ".asciiz \"%s\""
asmByte  = printf ".byte %d"
asmByteEqu = printf ".byte %s"


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

-- AVR String --
data AvrString = AvrString { stringTag :: String, stringStr :: String  }


instance AvrTag AvrString where
   len a = length $ stringStr a
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
  len a = length (symbolName a) + 1 + 2 + 1 -- term zero + mask + word ptr to symbol
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

getHeaderSize a = 2 * length (trTraces a)
section = defToAsmLine ".section " ++ show avrSection 
avrTracesHeader a text arr = section ++ ret ++ ret ++ header a text arr 

data AvrTraces = AvrTraces { trTraces :: [AvrSymbol]
                           , trCpuType :: String
                           , trCpuFreq :: Int } deriving Show

instance AvrTag AvrTraces where
  len a = getHeaderSize a + sum (map len (trTraces a))
  tag a = "AVR_MMCU_TAG_VCD_TRACE"
  getSource a = avrTracesHeader a "All My Info" [ concatMap getSource $ trTraces a
                                                , getSource $ AvrCpu (trCpuType a) (trCpuFreq a) ]

traceFromRecord :: Y2T.TraceRecord -> String
traceFromRecord tr =
  let
    traceObject = Avr.AvrTraces { trTraces =  map (`AvrSymbol` 0) $ Y2T.vars tr
                                , trCpuType = Y2T.cpuType tr
                                , trCpuFreq = Y2T.cpuFreq tr}
  in
    getSource traceObject

ttest = Y2T.TraceRecord { Y2T.cpuType = "atmega88"
                        , Y2T.cpuFreq = 20000000
                        , Y2T.vars = ["DDRB","TCCR0B"] }

