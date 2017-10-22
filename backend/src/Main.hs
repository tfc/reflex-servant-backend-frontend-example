{-# LANGUAGE DataKinds     #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE LambdaCase    #-}
{-# LANGUAGE TypeOperators #-}

module Main where

import           Lib                      hiding (main)
import           Network.Wai.Handler.Warp
import qualified Options.Applicative      as O
import           Servant
import           System.IO

main :: IO ()
main = do
  CliArgs jsExePath <- O.execParser $
        O.info (O.helper <*> cliParser)
               (O.fullDesc <> O.header "reflex-servant-backend-frontend example backend app")
  let port = 3000
      settings =
        setPort port $
          setBeforeMainLoop (hPutStrLn stderr ("listening on port " ++ show port)) $
            defaultSettings
  runSettings settings =<< return (serve itemApi $ server jsExePath)


data CliArgs = CliArgs FilePath

cliParser :: O.Parser CliArgs
cliParser = CliArgs <$> O.argument O.str (O.metavar "<frontend.jsexe folder>")

server :: FilePath -> Server ItemApi
server jsExePath =
  getItems
    :<|> getItemById
    :<|> serveDirectoryFileServer jsExePath

getItems :: Handler [Item]
getItems = return $ map (uncurry Item) items

getItemById :: Integer -> Handler Item
getItemById index = maybe (throwError err404) (return . Item index) $ lookup index items

items :: [(Integer, String)]
items = zip [0..] ["key", "shoe", "box", "ball"]
