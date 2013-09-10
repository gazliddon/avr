module Main where

import Data.Yaml.YamlLight
import qualified Data.ByteString.Char8 as BS
import Data.Maybe
import Control.Applicative
import qualified Avr 
import qualified YamlToTrace as Y2T

---
testFileName = "test.yaml"

writeCFile fileName yaml = 
   writeFile fileName <$> (Avr.traceFromRecord <$> Y2T.getValues yaml)
---
main = do
  fileData <- parseYamlFile testFileName
  putStrLn "hello"
  writeCFile "poo.txt" <$> parseYamlFile testFileName

