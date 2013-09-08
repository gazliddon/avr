module Main where

import Data.Yaml.YamlLight
import qualified Data.ByteString.Char8 as BS
import Data.Maybe
import Control.Applicative

---
testFileName = "test.yaml"

---
data TraceRecord = TraceRecord { cpuType :: String
                               , vars :: [String] 
} deriving (Show)

data AvrTagEnum =
	  AVR_MMCU_TAG
	| AVR_MMCU_TAG_NAME
	| AVR_MMCU_TAG_FREQUENCY
	| AVR_MMCU_TAG_VCC
	| AVR_MMCU_TAG_AVCC
	| AVR_MMCU_TAG_AREF
	| AVR_MMCU_TAG_LFUSE
	| AVR_MMCU_TAG_HFUSE
	| AVR_MMCU_TAG_EFUSE
	| AVR_MMCU_TAG_SIGNATURE
	| AVR_MMCU_TAG_SIMAVR_COMMAND
	| AVR_MMCU_TAG_SIMAVR_CONSOLE
	| AVR_MMCU_TAG_VCD_FILENAME
	| AVR_MMCU_TAG_VCD_PERIOD
	| AVR_MMCU_TAG_VCD_TRACE
  deriving (Enum)

data AvrStr = AvrStr {
  strTag :: AvrTagEnum,
  strName :: String
}

data AvrLong = AvrLong {
  longTag :: AvrTagEnum,
  longVal :: Integer
}

data AvrAddr = AvrAddr {
  addrTag :: AvrTagEnum,
  addrVal :: String
}

data AvrTrace  = AvrTrace {
  traceTag :: AvrTagEnum,
  traceMask :: Integer,
  traceAddr :: String,
  traceName :: String
}



---
getValues yaml = do
  let getElem a  = lookupYL ((YStr . BS.pack) a) yaml 

  cpuElem <- getElem "cpu"
  traceList <- getElem "trace"
  traceSeq <- unSeq traceList

  let m = map (BS.unpack . fromJust) $ filter isJust $ map unStr traceSeq
  
  cpuString <- BS.unpack <$> unStr cpuElem

  return $ TraceRecord cpuString m

---
traceRecordToSource :: TraceRecord -> String
traceRecordToSource t = 
  cpuType t

---
makeCFile yaml = do
  fileData <- getValues yaml
  let newStr = traceRecordToSource fileData
  return newStr
  
---
main = do
  let y = makeCFile <$> parseYamlFile testFileName
  return y


