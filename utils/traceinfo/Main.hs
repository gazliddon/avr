module Main where

import Data.Yaml.YamlLight
import qualified Data.ByteString.Char8 as BS
import Data.Maybe
import Control.Applicative
import qualified AvrFromTraceRecord as AvrTr 
import qualified YamlToTrace as Y2T
import Data.Typeable
import System.Environment

---
testFileName = "test.yaml"

getSourceCode yaml = 
  AvrTr.makeSourceFromRec $ Y2T.getValues yaml

---
main = do
  yaml <- (head <$> getArgs) >>= parseYamlFile
  putStrLn $ getSourceCode yaml
  return ()

