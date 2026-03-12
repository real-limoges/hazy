module Hazy.Inference.MamdaniSpec (spec) where

import Data.Map.Strict qualified as Map
import Test.Hspec
import Test.QuickCheck

import Hazy.Core.Membership (trapezoidal, triangular)
import Hazy.Core.Types (FuzzySet (..))
import Hazy.Inference.Evaluate (evaluate)
import Hazy.Inference.Types

spec :: Spec
spec = do
    describe "mamdani" $ do
        it "single rule, single input/output produces expected output" $ do
            let result = evaluate fanFIS (Map.singleton "temperature" 75.0)
            case Map.lookup "fan" result of
                Nothing -> expectationFailure "missing 'fan' output"
                Just v -> v `shouldSatisfy` (\x -> x > 50 && x <= 100)

        it "returns midpoint-ish when input is at boundary between terms" $ do
            let result = evaluate fanFIS (Map.singleton "temperature" 50.0)
            case Map.lookup "fan" result of
                Nothing -> expectationFailure "missing 'fan' output"
                Just v -> v `shouldSatisfy` (\x -> x >= 0 && x <= 100)

        it "low temperature produces low fan output" $ do
            let result = evaluate fanFIS (Map.singleton "temperature" 10.0)
            case Map.lookup "fan" result of
                Nothing -> expectationFailure "missing 'fan' output"
                Just v -> v `shouldSatisfy` (< 50)

        it "multi-output FIS returns all output keys" $ do
            let result = evaluate multiOutFIS (Map.singleton "temperature" 75.0)
            Map.member "fan" result `shouldBe` True
            Map.member "alarm" result `shouldBe` True

        it "output values lie within universe bounds" $
            property $ \temp' ->
                let temp = clampTo 0 100 (temp' :: Double)
                    result = evaluate fanFIS (Map.singleton "temperature" temp)
                 in case Map.lookup "fan" result of
                        Nothing -> False
                        Just v -> v >= -0.01 && v <= 100.01

-- Helper: clamp a value to a range
clampTo :: Double -> Double -> Double -> Double
clampTo lo hi x = max lo (min hi x)

-- A simple fan controller FIS for testing
fanFIS :: FIS
fanFIS =
    FIS
        { fisName = "fan_controller"
        , fisInputs = Map.singleton "temperature" tempVar
        , fisOutputs = Map.singleton "fan" fanVar
        , fisRules = [rule1, rule2]
        , fisMethod = Mamdani
        }
  where
    tempLow = FuzzySet "low" (triangular 0 0 50) (0, 100)
    tempHigh = FuzzySet "high" (triangular 50 100 100) (0, 100)
    tempVar =
        LinguisticVar
            "temperature"
            (Map.fromList [("low", tempLow), ("high", tempHigh)])
            (0, 100)
    fanLow = FuzzySet "low" (trapezoidal 0 0 30 50) (0, 100)
    fanHigh = FuzzySet "high" (trapezoidal 50 70 100 100) (0, 100)
    fanVar =
        LinguisticVar
            "fan"
            (Map.fromList [("low", fanLow), ("high", fanHigh)])
            (0, 100)
    rule1 = FuzzyRule [("temperature", "low")] [("fan", "low")]
    rule2 = FuzzyRule [("temperature", "high")] [("fan", "high")]

-- A multi-output FIS for testing
multiOutFIS :: FIS
multiOutFIS =
    FIS
        { fisName = "multi_out"
        , fisInputs = Map.singleton "temperature" tempVar
        , fisOutputs = Map.fromList [("fan", fanVar), ("alarm", alarmVar)]
        , fisRules = [rule1, rule2]
        , fisMethod = Mamdani
        }
  where
    tempHigh = FuzzySet "high" (triangular 50 100 100) (0, 100)
    tempLow = FuzzySet "low" (triangular 0 0 50) (0, 100)
    tempVar =
        LinguisticVar
            "temperature"
            (Map.fromList [("low", tempLow), ("high", tempHigh)])
            (0, 100)
    fanOn = FuzzySet "on" (trapezoidal 50 70 100 100) (0, 100)
    fanVar =
        LinguisticVar
            "fan"
            (Map.singleton "on" fanOn)
            (0, 100)
    alarmOn = FuzzySet "on" (trapezoidal 50 70 100 100) (0, 100)
    alarmVar =
        LinguisticVar
            "alarm"
            (Map.singleton "on" alarmOn)
            (0, 100)
    rule1 = FuzzyRule [("temperature", "high")] [("fan", "on")]
    rule2 = FuzzyRule [("temperature", "high")] [("alarm", "on")]
