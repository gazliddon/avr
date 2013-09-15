module Main where

import System.Environment

import Text.ParserCombinators.Parsec 
import Control.Monad hiding ( (<|>) )
import Control.Applicative hiding (many, (<|>) )

import ParsecHelper

data VCDVal = Command String String
            | TimeScale Int 
            | Var Int String String
            | Event Int Int String
            | Eof deriving (Show)

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

isCommand (Command{}) = True
isCommand _ = False

data VCDFile = VCDFile TimeScale [Var] [Event] deriving Show


main = do
  file <- head <$> getArgs
  test <- getCommands <$> readFile file
  print (filter (not . isCommand) test)


