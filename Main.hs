{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeOperators #-}

module Main where

import Control.Monad.Except (liftIO)
import Data.Aeson (ToJSON, FromJSON, parseJSON,genericParseJSON, defaultOptions, eitherDecode)
import Data.Text (Text, pack, unpack)
import qualified Data.Text.Encoding as TextEncoding (encodeUtf8)
import GHC.Generics (Generic)
import Network.HTTP.Client.TLS (newTlsManager)
import Network.Wai.Handler.Warp (run)
import Servant

import qualified Data.ByteString.Lazy.Char8 as BSL
import qualified Network.HTTP.Client as HttpClient

data GNewsResponse = GNewsResponse
  { totalArticles :: Int
  , resourceArticles :: [Article]
  }
  deriving (Show, Generic, ToJSON)

data Article = Article
  { title :: Text
  , description :: Text
  , content :: Text
  , url :: Text
  , image :: Text
  , publishedAt :: Text
  , source :: Source
  }
  deriving (Show, Generic, ToJSON)

data Source = Source
  { name :: Text
  , sourceUrl :: Text
  }
  deriving (Show, Generic, ToJSON)

instance FromJSON GNewsResponse where
  parseJSON = genericParseJSON defaultOptions

instance FromJSON Article where
  parseJSON = genericParseJSON defaultOptions

instance FromJSON Source where
  parseJSON = genericParseJSON defaultOptions

type GNewsAPI =
  "search" :> QueryParam "q" Text :> QueryParam "apikey" Text :> Get '[JSON] GNewsResponse

gnewsApi :: Proxy GNewsAPI
gnewsApi = Proxy

appWithGNews :: Server GNewsAPI
appWithGNews = searchArticlesHandler

searchArticlesHandler :: Maybe Text -> Maybe Text -> Handler GNewsResponse
searchArticlesHandler mQuery mApiKey = do
  case (mQuery, mApiKey) of
    (Just query, Just apiKey) -> do
      let gnewsApiUrl = "https://gnews.io/api/v4/search"
      let params = [("q", unpack query), ("apikey", unpack apiKey)]
      liftIO $ putStrLn $ "Request Parameters: " ++ show params -- Debug print
      gnewsResponse <- liftIO $ getWithParams gnewsApiUrl params
      liftIO $ putStrLn $ "Response: " ++ show gnewsResponse -- Debug print
      case eitherDecode gnewsResponse of
        Right response -> return response
        Left err -> throwError $ err500 { errBody = BSL.pack err }
    _ -> throwError $ err400 { errBody = "Query and API key must be provided." }

getWithParams :: String -> [(String, String)] -> IO BSL.ByteString
getWithParams reqUrl params = do
  manager <- newTlsManager
  let encodedParams = map (\(k, v) -> (TextEncoding.encodeUtf8 $ pack k, Just $ TextEncoding.encodeUtf8 $ pack v)) params
  let request = HttpClient.setQueryString encodedParams $ HttpClient.parseRequest_ reqUrl
  response <- HttpClient.httpLbs request manager
  return $ HttpClient.responseBody response

type API = "gnews" :> GNewsAPI

api :: Proxy API
api = Proxy

app :: Application
app = serve api appWithGNews

main :: IO ()
main = do
  putStrLn "Application launching..."
  run (8085 :: Int) app
