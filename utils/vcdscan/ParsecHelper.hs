 module ParsecHelper where

import Text.ParserCombinators.Parsec 
import Control.Monad hiding ( (<|>) )
import Control.Applicative hiding (many, (<|>) )

binStrToDec :: String -> Int
binStrToDec = foldr (\c s -> s * 2 + c) 0 . reverse . map c2i
    where c2i c = if c == '0' then 0 else 1

parseIdentifier :: Parser String
parseIdentifier = (:) <$> letter <*> (many $ alphaNum <|> char '_') 

parseCommandStr :: Parser String
parseCommandStr =  char '$' *> parseIdentifier 

parseInt :: Parser Int
parseInt = liftM (read) $ many1 digit

parseBinary :: Parser Int
parseBinary = oneOf "b" *>  (binStrToDec <$> many (oneOf "01"))

parseId :: Parser String
parseId = many (noneOf " \n\t\r")

toChoice a =  choice $ map try a

