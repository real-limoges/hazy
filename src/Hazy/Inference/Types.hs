module Hazy.Inference.Types (
    LinguisticVar (..),
    FuzzyRule (..),
    InferenceMethod (..),
    FIS (..),
    InferenceTrace (..),
) where

import Data.Map.Strict (Map)
import Data.Text (Text)

import Hazy.Core.Types (Degree, FuzzySet)

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

{- | Full intermediate state of a Mamdani inference run, intended for
  visualization and teaching. Returned by 'Hazy.Inference.Evaluate.mamdaniTrace'.
-}
data InferenceTrace = InferenceTrace
    { traceInputDegrees :: Map Text (Map Text Degree)
    {- ^ For each input variable that received a crisp value, the degree of
    membership in each of the variable's terms at that value.
    -}
    , traceRuleStrengths :: [Degree]
    -- ^ Firing strength per rule, in the same order as @fisRules fis@.
    , traceOutputCurves :: Map Text [(Double, Degree)]
    {- ^ For each output variable, the aggregated (max of clipped consequents)
    membership curve sampled across the combined universe. Empty list when
    no rules fire for that output.
    -}
    , traceCrisp :: Map Text Double
    -- ^ Defuzzified crisp outputs, matching what @mamdani@ / @evaluate@ return.
    }
    deriving (Eq, Show)
