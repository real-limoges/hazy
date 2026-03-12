module Hazy.Inference.Mamdani (
    mamdani,
) where

import Data.Map.Strict (Map)
import Data.Map.Strict qualified as Map
import Data.Maybe (mapMaybe)
import Data.Text (Text)

import Hazy.Core.Defuzzify (DefuzzMethod (..), defuzzify)
import Hazy.Core.Types (Degree, FuzzySet (..))
import Hazy.Inference.Types (FIS (..), FuzzyRule (..), LinguisticVar (..))

-- | Fuzzify -> rule evaluation -> consequent clipping -> aggregation -> defuzzify.
mamdani :: FIS -> Map Text Double -> Map Text Double
mamdani fis inputs =
    let ruleResults = map (evalRule fis inputs) (fisRules fis)
        grouped = groupConsequents ruleResults
     in Map.map (defuzzify Centroid) grouped

evalRule :: FIS -> Map Text Double -> FuzzyRule -> [(Text, FuzzySet, Degree)]
evalRule fis inputs rule =
    let alpha = firingStrength fis inputs (ruleAntecedent rule)
     in [ (outVar, fs, alpha)
        | (outVar, termName) <- ruleConsequent rule
        , Just lv <- [Map.lookup outVar (fisOutputs fis)]
        , Just fs <- [Map.lookup termName (lvTerms lv)]
        ]

-- | Antecedent firing strength via min t-norm.
firingStrength :: FIS -> Map Text Double -> [(Text, Text)] -> Degree
firingStrength fis inputs antecedents =
    case mapMaybe (evalAntecedent fis inputs) antecedents of
        [] -> 0.0
        degrees -> minimum degrees

evalAntecedent :: FIS -> Map Text Double -> (Text, Text) -> Maybe Degree
evalAntecedent fis inputs (varName, termName) = do
    lv <- Map.lookup varName (fisInputs fis)
    fs <- Map.lookup termName (lvTerms lv)
    crisp <- Map.lookup varName inputs
    pure (fsMf fs crisp)

groupConsequents :: [[(Text, FuzzySet, Degree)]] -> Map Text [(FuzzySet, Degree)]
groupConsequents = foldl' addTriple Map.empty . concat
  where
    addTriple acc (outVar, fs, alpha) =
        Map.insertWith (++) outVar [(fs, alpha)] acc
