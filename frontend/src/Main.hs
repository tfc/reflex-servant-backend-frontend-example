{-# LANGUAGE DataKinds           #-}
{-# LANGUAGE FlexibleContexts    #-}
{-# LANGUAGE GADTs               #-}
{-# LANGUAGE OverloadedStrings   #-}
{-# LANGUAGE RankNTypes          #-}
{-# LANGUAGE RecursiveDo         #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Main where

import           Control.Monad.Fix (MonadFix)
import           Data.Proxy
import qualified Data.Text         as T
import           Lib
import           Reflex.Dom
import           Servant.API
import           Servant.Reflex
import           Text.Read         (readMaybe)

numberInput :: DomBuilder t m => m (Dynamic t (Maybe Integer))
numberInput = do
   n <- inputElement $ def
     & inputElementConfig_initialValue .~ "0"
     & inputElementConfig_elementConfig . elementConfig_initialAttributes .~ ("type" =: "number")
   return . fmap (readMaybe . T.unpack) $ _inputElement_value n

numInput :: (DomBuilder t m, MonadHold t m, MonadFix m) => m (Dynamic t Integer)
numInput = do
   n <- inputElement $ def
     & inputElementConfig_initialValue .~ "0"
     & inputElementConfig_elementConfig . elementConfig_initialAttributes .~ ("type" =: "number")
   foldDynMaybe
                (\maybeInt _ -> maybeInt)
                0
                (updated $ fmap (readMaybe . T.unpack) $ _inputElement_value n)

w :: forall t m .
  ( SupportsServantReflex t m,
    DomBuilder t m,
    DomBuilderSpace m ~ GhcjsDomSpace,
    MonadFix m,
    PostBuild t m,
    MonadHold t m
  )
  => m ()
w = do

  let (listItems :<|> getItem :<|> _) = client (Proxy :: Proxy ItemApi)
                                               (Proxy :: Proxy m)
                                               (Proxy :: Proxy ())
                                               (constDyn (BasePath "/"))
  el "div" $ do
    -- create button that triggers the request for the list
    itemButton <- divClass "button" $ button "List items"
    itemListResponse :: Event t (ReqResult () [Item]) <- listItems itemButton
    -- show list
    dynText =<< holdDyn "Waiting" (T.pack . show . reqSuccess <$> itemListResponse)

    -- create textfield that emits integer dynamic
    num :: Dynamic t Integer <- numInput
    let numberChangeEvent = (fmapCheap (const ()) $ updated num)
    itemResponse :: Event t (ReqResult () Item) <- getItem (Right <$> num) numberChangeEvent
    -- show item
    dynText =<< holdDyn "Waiting" (T.pack . (maybe "not found" itemText) . reqSuccess <$> itemResponse)
    return ()
  return ()

main :: IO ()
main = mainWidget $ el "div" $ w
