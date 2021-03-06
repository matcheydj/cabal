-- | Utility json lib for Cabal
-- TODO: Remove it again.
module Distribution.Simple.Utils.Json
    ( Json(..)
    , renderJson
    ) where

data Json = JsonArray [Json]
          | JsonBool !Bool
          | JsonNull
          | JsonNumber !Int
          | JsonObject [(String, Json)]
          | JsonString !String

renderJson :: Json -> ShowS
renderJson (JsonArray objs)   =
  surround "[" "]" $ intercalate "," $ map renderJson objs
renderJson (JsonBool True)    = showString "true"
renderJson (JsonBool False)   = showString "false"
renderJson  JsonNull          = showString "null"
renderJson (JsonNumber n)     = shows n
renderJson (JsonObject attrs) =
  surround "{" "}" $ intercalate "," $ map render attrs
  where
    render (k,v) = (surround "\"" "\"" $ showString' k) . showString ":" . renderJson v
renderJson (JsonString s)     = surround "\"" "\"" $ showString' s

surround :: String -> String -> ShowS -> ShowS
surround begin end middle = showString begin . middle . showString end

showString' :: String -> ShowS
showString' xs = showStringWorker xs
    where
        showStringWorker :: String -> ShowS
        showStringWorker ('\"':as) = showString "\\\"" . showStringWorker as
        showStringWorker ('\\':as) = showString "\\\\" . showStringWorker as
        showStringWorker ('\'':as) = showString "\\\'" . showStringWorker as
        showStringWorker (x:as) = showString [x] . showStringWorker as
        showStringWorker [] = showString ""

intercalate :: String -> [ShowS] -> ShowS
intercalate sep = go
  where
    go []     = id
    go [x]    = x
    go (x:xs) = x . showString' sep . go xs
