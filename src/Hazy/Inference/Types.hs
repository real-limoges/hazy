module Hazy.Inference.Types (
    LinguisticVar (..),
    FuzzyRule (..),
    InferenceMethod (..),
    FIS (..),
) where

import Data.Map.Strict (Map)
import Data.Text (Text)

import Hazy.Core.Types (FuzzySet)

data LinguisticVar = LinguisticVar
    { lvName :: Text
    , lvTerms :: Map Text FuzzySet
    , lvBounds :: (Double, Double)
    }

data FuzzyRule = FuzzyRule
    { ruleAntecedent :: [(Text, Text)]
    , ruleConsequent :: [(Text, Text)]
    }
    deriving (Eq, Show)

data InferenceMethod = Mamdani | Sugeno
    deriving (Eq, Show)

data FIS = FIS
    { fisName :: Text
    , fisInputs :: Map Text LinguisticVar
    , fisOutputs :: Map Text LinguisticVar
    , fisRules :: [FuzzyRule]
    , fisMethod :: InferenceMethod
    }
