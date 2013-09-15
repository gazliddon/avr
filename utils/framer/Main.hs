{-# LANGUAGE TypeSynonymInstances, FlexibleInstances #-}

module Main where
import System.Environment
import Control.Applicative
import qualified YamlToTrace as Y2T
import Data.Yaml.YamlLight
import Data.List

import qualified Data.Yaml.YamlLight as YL
import qualified Data.ByteString.Char8 as BS

gnd y key = Y2T.getNoDefault y key
gdj y key def = Just (Y2T.get y key def)

testFile = "test.yaml"

data Line = Line String Int Int deriving Show


instance Y2T.GetYaml [Line] where getFun = Y2T.getSeq
instance Y2T.GetYaml Line where
  getFun y = Line <$> gnd y "name" <*> gnd y "duration" <*> gdj y "start" (-1)

testLine :: YL.YamlLight -> Maybe [Line]
testLine yaml = gnd yaml "testLineSeq"

accumFunc :: Int -> Line -> (Int, (Int, Int, String) ) 
accumFunc prev line@(Line name duration (-1) ) = (prev + duration, (prev + duration, duration, name))
accumFunc prev line@(Line name duration start) = (start + duration, ( start + duration, duration, name))

main = do
  text <- readFile testFile
  tline <- testLine <$> YL.parseYaml text
  let p =  mapAccumL accumFunc 0 <$> tline
  print p
  putStrLn $ show tline

