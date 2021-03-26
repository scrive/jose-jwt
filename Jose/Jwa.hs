{-# LANGUAGE OverloadedStrings #-}
{-# OPTIONS_HADDOCK prune #-}

module Jose.Jwa
    ( Alg (..)
    , JwsAlg (..)
    , JweAlg (..)
    , Enc (..)
    , encName
    )
where

import Control.Applicative (pure)
import Data.Aeson
import Data.Text (Text)
import Data.Tuple (swap)

-- | General representation of the @alg@ JWT header value.
data Alg = Signed JwsAlg | Encrypted JweAlg deriving (Eq, Show)

-- | The signature algorithms from the
-- <https://tools.ietf.org/html/rfc7518#section-3 JWA Spec>.
--
-- NB: @PS256@, @PS384@ and @PS512@ algorithms aren't implemented yet.
data JwsAlg = None | HS256 | HS384 | HS512 | RS256 | RS384 | RS512 | ES256 | ES384 | ES512 | PS256 | PS384 | PS512 | EdDSA deriving (Eq, Show, Read)

-- | The key management algorithms from the
-- <https://tools.ietf.org/html/rfc7518#section-4 JWA Spec>.
--
-- NB: @ECDH_ES@, @ECDH_ES_A128KW@, @ECDH_ES_A192KW@ and @DIR@ algorithms aren't implemented yet.
data JweAlg = RSA1_5 | RSA_OAEP | RSA_OAEP_256 | A128KW | A192KW | A256KW | ECDH_ES | ECDH_ES_A128KW | ECDH_ES_A192KW | DIR deriving (Eq, Show, Read)

-- | Content encryption algorithms from the
-- <https://tools.ietf.org/html/rfc7518#section-5 JWA Spec>.
data Enc = A128CBC_HS256 | A192CBC_HS384 | A256CBC_HS512 | A128GCM | A192GCM | A256GCM deriving (Eq, Show)

algs :: [(Text, Alg)]
algs = [("none", Signed None), ("HS256", Signed HS256), ("HS384", Signed HS384), ("HS512", Signed HS512), ("RS256", Signed RS256), ("RS384", Signed RS384), ("RS512", Signed RS512), ("ES256", Signed ES256), ("ES384", Signed ES384), ("ES512", Signed ES512), ("PS256", Signed PS256), ("PS384", Signed PS384), ("PS512", Signed PS512), ("EdDSA", Signed EdDSA), ("RSA1_5", Encrypted RSA1_5), ("RSA-OAEP", Encrypted RSA_OAEP), ("RSA-OAEP-256", Encrypted RSA_OAEP_256), ("A128KW", Encrypted A128KW), ("A192KW", Encrypted A192KW), ("A256KW", Encrypted A256KW), ("ECDH-ES", Encrypted ECDH_ES), ("ECDH-ES+A128KW", Encrypted ECDH_ES_A128KW), ("ECDH-ES+A192KW", Encrypted ECDH_ES_A192KW), ("dir", Encrypted DIR)]

algName :: Alg -> Text
algName a = let Just n = lookup a algNames in n

algNames :: [(Alg, Text)]
algNames = map swap algs

encs :: [(Text, Enc)]
encs = [("A128CBC-HS256", A128CBC_HS256), ("A256CBC-HS512", A256CBC_HS512), ("A192CBC-HS384", A192CBC_HS384), ("A128GCM", A128GCM), ("A192GCM", A192GCM), ("A256GCM", A256GCM)]

encName :: Enc -> Text
encName e = let Just n = lookup e encNames in n

encNames :: [(Enc, Text)]
encNames = map swap encs

instance FromJSON Alg where
    parseJSON = withText "Alg" $ \t ->
      maybe (fail "Unsupported alg") pure $ lookup t algs

instance ToJSON Alg where
    toJSON = String . algName

instance FromJSON JwsAlg where
    parseJSON = withText "JwsAlg" $ \t -> case lookup t algs of
        Just (Signed a) -> pure a
        _               -> fail "Unsupported JWS algorithm"

instance ToJSON JwsAlg where
    toJSON a = String . algName $ Signed a

instance FromJSON JweAlg where
    parseJSON = withText "JweAlg" $ \t -> case lookup t algs of
        Just (Encrypted a) -> pure a
        _                  -> fail "Unsupported JWE algorithm"

instance ToJSON JweAlg where
    toJSON a = String . algName $ Encrypted a

instance FromJSON Enc where
    parseJSON = withText "Enc" $ \t ->
      maybe (fail "Unsupported enc") pure $ lookup t encs

instance ToJSON Enc where
    toJSON = String . encName
