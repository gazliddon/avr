module Test where

import Text.ParserCombinators.Parsec 
import Control.Applicative hiding (many, (<|>) )
import Control.Monad hiding ( (<|>) )

data TestData =
    Num Int
  | Str String          deriving (Show)

parseIdentifier :: Parser String
parseIdentifier = do
  l <- letter
  r <- many (alphaNum <|> char '_')
  return $ l : r

pNum :: Parser TestData
pNum = Num <$> (liftM (read) $ many1 digit)

pStr :: Parser TestData
pStr = Str <$> parseIdentifier

test :: (Parser [TestData]) -> String -> String
test parseFunc str = case parse parseFunc "TST" str of
  Left err -> "No match " ++ show err
  Right val -> "Found " ++ show val

brokenParser = (pNum <|> pStr) `endBy` spaces

str = "a21219938 sakjskaskas 222 ksjajksa"
broke = do putStrLn $ test brokenParser str
 
