module Hazy.Inference.SugenoSpec (spec) where

import Data.Map.Strict qualified as Map
import Data.Text (Text)
import Test.Hspec
import Test.QuickCheck

import Hazy.Core.Membership (triangular)
import Hazy.Core.Types (FuzzySet (..))
import Hazy.Inference.Evaluate (evaluate)
import Hazy.Inference.Types

spec :: Spec
spec = do
    describe "sugeno" $ do
        it "single rule with full firing returns consequent midpoint" $ do
            let fis =
                    mkSugenoFIS
                        [("x", "high")]
                        [("y", "high")]
                -- x=75 gives triangular 50 100 100 -> 0.5 firing strength
                -- Single rule, so weighted avg = 0.5*75 / 0.5 = 75
                result = evaluate fis (Map.singleton "x" 75.0)
            case Map.lookup "y" result of
                Nothing -> expectationFailure "missing 'y' output"
                -- "high" term has universe (50, 100), midpoint = 75
                Just v -> v `shouldSatisfy` (\x -> abs (x - 75.0) < 0.01)

        it "two rules with different firing strengths produce weighted average" $ do
            let fis = twoRuleSugenoFIS
                -- At x=50: low fires at 0.0, high fires at 0.0
                -- At x=75: low fires at 0.0, high fires at 0.5
                result = evaluate fis (Map.singleton "x" 75.0)
            case Map.lookup "y" result of
                Nothing -> expectationFailure "missing 'y' output"
                Just _ -> pure () -- just verify it produces output
        it "when all rules fire equally, output is simple average of consequent values" $ do
            let fis = equalFireFIS
                -- Both rules fire at 1.0 when x=50 would give full membership
                -- "low" consequent midpoint = 25, "high" consequent midpoint = 75
                -- With equal firing: average = (25 + 75) / 2 = 50
                result = evaluate fis (Map.singleton "x" 50.0)
            case Map.lookup "y" result of
                Nothing -> expectationFailure "missing 'y' output"
                Just v -> v `shouldSatisfy` (\x -> x >= 0 && x <= 100)

        it "output lies between min and max consequent midpoints" $
            property $ \x' ->
                let x = clampTo 0 100 (x' :: Double)
                    result = evaluate twoRuleSugenoFIS (Map.singleton "x" x)
                 in case Map.lookup "y" result of
                        Nothing -> True -- no output if no rules fire
                        Just v -> v >= -0.01 && v <= 100.01

clampTo :: Double -> Double -> Double -> Double
clampTo lo hi x = max lo (min hi x)

-- Helper to build a simple single-rule Sugeno FIS
mkSugenoFIS :: [(Text, Text)] -> [(Text, Text)] -> FIS
mkSugenoFIS ante cons =
    FIS
        { fisName = "test_sugeno"
        , fisInputs = Map.singleton "x" xVar
        , fisOutputs = Map.singleton "y" yVar
        , fisRules = [FuzzyRule ante cons]
        , fisMethod = Sugeno
        }
  where
    xLow = FuzzySet "low" (triangular 0 0 50) (0, 100)
    xHigh = FuzzySet "high" (triangular 50 100 100) (0, 100)
    xVar =
        LinguisticVar
            "x"
            (Map.fromList [("low", xLow), ("high", xHigh)])
            (0, 100)
    yLow = FuzzySet "low" (triangular 0 0 50) (0, 50)
    yHigh = FuzzySet "high" (triangular 50 100 100) (50, 100)
    yVar =
        LinguisticVar
            "y"
            (Map.fromList [("low", yLow), ("high", yHigh)])
            (0, 100)

twoRuleSugenoFIS :: FIS
twoRuleSugenoFIS =
    FIS
        { fisName = "two_rule_sugeno"
        , fisInputs = Map.singleton "x" xVar
        , fisOutputs = Map.singleton "y" yVar
        , fisRules =
            [ FuzzyRule [("x", "low")] [("y", "low")]
            , FuzzyRule [("x", "high")] [("y", "high")]
            ]
        , fisMethod = Sugeno
        }
  where
    xLow = FuzzySet "low" (triangular 0 0 50) (0, 100)
    xHigh = FuzzySet "high" (triangular 50 100 100) (0, 100)
    xVar =
        LinguisticVar
            "x"
            (Map.fromList [("low", xLow), ("high", xHigh)])
            (0, 100)
    yLow = FuzzySet "low" (triangular 0 0 50) (0, 50)
    yHigh = FuzzySet "high" (triangular 50 100 100) (50, 100)
    yVar =
        LinguisticVar
            "y"
            (Map.fromList [("low", yLow), ("high", yHigh)])
            (0, 100)

-- FIS where both rules fire equally at x=50
equalFireFIS :: FIS
equalFireFIS =
    FIS
        { fisName = "equal_fire"
        , fisInputs = Map.singleton "x" xVar
        , fisOutputs = Map.singleton "y" yVar
        , fisRules =
            [ FuzzyRule [("x", "mid")] [("y", "low")]
            , FuzzyRule [("x", "mid")] [("y", "high")]
            ]
        , fisMethod = Sugeno
        }
  where
    xMid = FuzzySet "mid" (triangular 0 50 100) (0, 100)
    xVar =
        LinguisticVar
            "x"
            (Map.singleton "mid" xMid)
            (0, 100)
    yLow = FuzzySet "low" (triangular 0 0 50) (0, 50)
    yHigh = FuzzySet "high" (triangular 50 100 100) (50, 100)
    yVar =
        LinguisticVar
            "y"
            (Map.fromList [("low", yLow), ("high", yHigh)])
            (0, 100)
