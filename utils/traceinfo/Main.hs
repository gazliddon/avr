module Main where

import Data.Yaml.YamlLight
import qualified Data.ByteString.Char8 as BS
import Data.Maybe
import Control.Applicative
import qualified Avr 
import qualified YamlToTrace as Y2T
import Data.Typeable

---
testFileName = "test.yaml"

getSourceCode yaml =
  Avr.traceFromRecord <$> Y2T.getValues yaml

---
main = do
  fileText <- readFile testFileName
  putStrLn fileText
  fileData <- parseYaml fileText
  let sourceCode = fromJust $ getSourceCode fileData
  let x =  typeOf sourceCode
  putStrLn sourceCode
  return ()

