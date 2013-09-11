{-# LANGUAGE TypeSynonymInstances, FlexibleInstances #-}

module YamlToTrace where

import qualified Data.Yaml.YamlLight as YL
import qualified Data.ByteString.Char8 as BS
import Control.Applicative
import Control.Monad
import Data.Maybe

-- Generic code for fetching things out of yaml with default values

class GetYaml a where

  getFun :: YL.YamlLight -> Maybe a

  get :: YL.YamlLight -> String -> a -> a
  get yaml key defaultValue = fromMaybe defaultValue $ (YL.lookupYL . YL.YStr . BS.pack) key yaml >>= getFun 

  getSeq :: YL.YamlLight -> Maybe [a]
  getSeq y = map fromJust <$> filter isJust <$> map getFun <$> YL.unSeq y

  getGeneric :: (Read a) => YL.YamlLight -> Maybe a
  getGeneric y = getFun y >>= Just . read

instance GetYaml String   where getFun y =  YL.unStr y >>= Just . BS.unpack

instance GetYaml Int      where getFun =    getGeneric   
instance GetYaml [String] where getFun =    getSeq 


-- Trace record stuff
data TraceRecord = TraceRecord { cpuType ::   String
                               , cpuFreq ::   Int
                               , vars ::      [String]
                               , vcdFile ::   String
                               , vcdPeriod :: Int
} deriving (Show)

getValues yaml= let get' key def = get yaml key def
  in  TraceRecord {
                  cpuType =   get' "cpu" "atmega88"
                , cpuFreq =   get' "freq" 20000000
                , vars =      get' "trace" []
                , vcdFile =   get' "vcdfile" "./test.vcd"
                , vcdPeriod = get' "vcdperiod" 1 }

