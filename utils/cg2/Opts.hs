{-# LANGUAGE DeriveDataTypeable #-}
module Opts where
import System.Console.CmdArgs


data Options = Options { files :: [FilePath]
                       , verbose :: Bool
                       , out :: FilePath } deriving (Show, Data, Typeable)

options = Options { files = ["gazgame.png"] &= args &= typ  "IN FILES"
                  , verbose = False
                  , out = "out.asm" &= typFile }

getOpts = cmdArgs options 
