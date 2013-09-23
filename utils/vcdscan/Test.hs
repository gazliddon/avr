module Test where

import Control.Applicative

import VCDVal
import VCDParse
import Analyse

test = do
  coms <- getCommands <$> readFile "test.vcd"
  let hs = findToggles "mem_PORTB" 2  $ coms
  putStrLn .unlines . map show $ hs 



