module Hazy.Inference.Sugeno (
    sugeno,
) where

import Data.Map.Strict (Map)
import Data.Map.Strict qualified as Map
import Data.Maybe (mapMaybe)
import Data.Text (Text)

import Hazy.Core.Types (Degree, FuzzySet (..))
import Hazy.Inference.Types (FIS (..), FuzzyRule (..), LinguisticVar (..))

-- | Zero-order Sugeno: fuzzify -> rule evaluation -> weighted average of consequent midpoints.
sugeno :: FIS -> Map Text Double -> Map Text Double
sugeno fis inputs =
    let ruleResults = map (evalRule fis inputs) (fisRules fis)
        grouped = groupConsequents ruleResults
     in Map.map weightedAverage grouped

weightedAverage :: [(Double, Degree)] -> Double
weightedAverage pairs =
    let num = sum [v * w | (v, w) <- pairs]
        den = sum [w | (_, w) <- pairs]
     in if den == 0 then 0.0 else num / den

evalRule :: FIS -> Map Text Double -> FuzzyRule -> [(Text, Double, Degree)]
evalRule fis inputs rule =
    let alpha = firingStrength fis inputs (ruleAntecedent rule)
     in [ (outVar, consequentMidpoint fs, alpha)
        | (outVar, termName) <- ruleConsequent rule
        , Just lv <- [Map.lookup outVar (fisOutputs fis)]
        , Just fs <- [Map.lookup termName (lvTerms lv)]
        ]

-- | Universe midpoint as the constant consequent output.
consequentMidpoint :: FuzzySet -> Double
consequentMidpoint fs =
    let (lo, hi) = fsUniverse fs
     in (lo + hi) / 2

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

groupConsequents :: [[(Text, Double, Degree)]] -> Map Text [(Double, Degree)]
groupConsequents = foldl' addTriple Map.empty . concat
  where
    addTriple acc (outVar, val, alpha) =
        Map.insertWith (++) outVar [(val, alpha)] acc
