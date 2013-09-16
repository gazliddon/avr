module Main where

import System.Environment

import Text.ParserCombinators.Parsec 
import Control.Monad hiding ( (<|>) )
import Control.Applicative hiding (many, (<|>) )

import ParsecHelper

data TimeUnit = TimeUnit {tuSymbol :: String, tuName :: String, tuHz :: Float}

seconds =      TimeUnit "s"  "seconds"       1
milliSeconds = TimeUnit "ms" "milliseconds" (1 / 1000)
microSeconds = TimeUnit "us" "microseconds" ( 1 / 1000 / 1000)
nanoSeconds =  TimeUnit "ns" "nanoseconds"  ( 1 / 1000 / 1000 / 1000)


unitsToHz "s" = Right (TimeUnit 
unitsToHz "ms" =



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


