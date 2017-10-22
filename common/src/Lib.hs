{-# LANGUAGE DataKinds     #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE TypeOperators #-}

module Lib where

import           Data.Aeson
import           Data.Proxy
import           GHC.Generics
import           Servant.API

type ItemApi =
  "item" :> Get '[JSON] [Item]
    :<|> "item" :> Capture "itemId" Integer :> Get '[JSON] Item
    :<|> Raw

itemApi :: Proxy ItemApi
itemApi = Proxy

data Item = Item
  { itemId   :: Integer,
    itemText :: String
  }
  deriving (Eq, Show, Generic)

instance ToJSON   Item
instance FromJSON Item
