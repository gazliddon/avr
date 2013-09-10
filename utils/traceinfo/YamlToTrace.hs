module YamlToTrace where

import qualified  Data.Yaml.YamlLight as YL
import qualified Data.ByteString.Char8 as BS
import Control.Applicative
import Control.Monad
import Data.Maybe

data TraceRecord = TraceRecord { cpuType :: String
                               , cpuFreq :: Int
                               , vars :: [String] 
} deriving (Show)

---
getElem yaml key = YL.lookupYL ((YL.YStr . BS.pack) key) yaml
getStr yaml = YL.unStr yaml >>= Just . BS.unpack
getSeq yaml = map fromJust <$> filter isJust <$> map getStr <$> YL.unSeq yaml

yStr yaml key = getElem yaml key >>= getStr
yNum yaml key = yStr yaml key >>= Just . (\x -> read x :: Int)
yStrSeq yaml key =  getElem yaml key >>= getSeq

getValues y = TraceRecord <$> yStr y "cpu" <*>  yNum y "freq" <*> yStrSeq y "trace"

