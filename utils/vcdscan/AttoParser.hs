{-# LANGUAGE OverloadedStrings #-}
module AttoParser where 
 
import Data.Attoparsec.Char8 as A
import Control.Applicative

import qualified Data.ByteString as B
import qualified Data.ByteString.Char8 as X 
import qualified Data.Map as Map
import Data.Maybe

-- Data Structures
--
data Command =   Var { vId  :: B.ByteString
                     , vSymbol :: B.ByteString }
               | Unknown deriving (Show)

instance Ord Command where compare (Var a _) (Var b _) = compare a b
instance Eq  Command where (Var a _) == (Var b _) = a == b

data Event = Event { evTime :: Int
                   , evMask :: Int
                   , evId :: B.ByteString
                   , evSymbol :: B.ByteString } deriving (Show)

data VFile = VFile { vfVars :: [Command]
                   , vfEvents :: [Event] } deriving (Show) 


isVar :: Command -> Bool
isVar Var{} = True
isVar _     = False

--- Parsing stuff 
stringSkipSpace str = string str <* skipSpace

idParser :: Parser B.ByteString
idParser  =  A.takeWhile (not . isSpace) <* skipSpace

endParser :: Parser ()
endParser = string "$end" *> skipSpace

varParser :: Parser Command
varParser = do
  id <- stringSkipSpace "$var" *> stringSkipSpace "wire 8" *> idParser
  symbol <- idParser <* endParser
  pure $ Var id symbol 

unknownParser :: Parser Command
unknownParser = do
  char '$' <* A.manyTill anyChar (try (string "$end")) <* skipSpace
  pure Unknown

binStrToDec' = foldr (\c s -> s * 2 + c) 0 . reverse . map c2i
    where c2i c = if c == '0' then 0 else 1

binary :: Parser Int
binary = do
  char 'b'
  val <- X.unpack <$> A.takeWhile (inClass "01")
  pure $ binStrToDec' val

eventParser :: Parser Event
eventParser = do
  time <- char '#' *> decimal <* skipSpace
  mask <- binary <* skipSpace
  id <- idParser  
  pure $ Event time mask id "null" 

-- Complete file parse
vcdFileParser :: Parser VFile
vcdFileParser = do
  vars <- filter isVar <$> many  (varParser <|> unknownParser)
  rawEvents <- many eventParser

  let varMap = Map.fromList $ map (\(Var id sym) -> (id, Var id sym)) vars
  let getSymbol i = vSymbol $ fromJust $ Map.lookup i varMap 
  let events = map (\(Event t m i _) -> Event t m i (getSymbol i)) rawEvents

  return $ VFile vars events

-- Public file parse
parseVCDFIle :: B.ByteString -> VFile
parseVCDFIle text = case parseOnly vcdFileParser text of
  Left err -> error "Error!"
  Right val -> val 

