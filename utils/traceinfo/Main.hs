module Main where

import Data.Yaml.YamlLight
import qualified Data.ByteString.Char8 as BS
import Data.Maybe
import Control.Applicative
import qualified AvrFromTraceRecord as AvrTr 
import qualified YamlToTrace as Y2T
import Data.Typeable

---
testFileName = "test.yaml"


getSourceCode yaml = 
  AvrTr.makeSourceFromRec $ Y2T.getValues yaml


---
main = do
  fileText <- readFile testFileName
  putStrLn fileText
  yaml <- parseYaml fileText
  putStrLn $ getSourceCode yaml
  return ()

