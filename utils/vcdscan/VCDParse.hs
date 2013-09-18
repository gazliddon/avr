module VCDParse where

import Text.ParserCombinators.Parsec 
import Control.Applicative hiding (many, (<|>) )
import Data.Maybe

import ParsecHelper
import TimeUnit
import VCDVal


startCom str = char '$' *> string str *> spaces
endCom = spaces <* string "$end" <* spaces

parseUnimplemented = Command <$> parseCommandStr <* spaces
                             <*> manyTill anyChar (try $ string "$end") <* spaces 

parseVar = Var <$> (startCom "var" *> string "wire" *> spaces *> parseInt <* spaces)
               <*> parseId <* spaces
               <*> parseIdentifier <* endCom  

parseTimeScale = TimeScale <$> ( startCom "timescale"
                               *> parseInt
                               <* spaces
                               <* string "ms"
                               <* endCom )

parseEvent = Event <$> (char '#' *> parseInt <* spaces)
                   <*> parseBinary <* spaces
                   <*> parseId <* spaces

mainParse = [ parseVar,
              parseTimeScale,
              parseEvent,
              parseUnimplemented ]
getCommands source = case parse (many $ toChoice mainParse) "VCD" source of
  Left err -> error $ "ERROR"
  Right val -> val


