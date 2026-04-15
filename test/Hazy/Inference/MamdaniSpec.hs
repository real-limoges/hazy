module Hazy.Inference.MamdaniSpec (spec) where

import Data.Map.Strict qualified as Map
import Test.Hspec
import Test.QuickCheck

import Hazy.Core.Membership (trapezoidal, triangular)
import Hazy.Core.Types (FuzzySet (..))
import Hazy.Inference.Evaluate (evaluate, mamdaniTrace)
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

    describe "mamdaniTrace" $ do
        it "crisp outputs match plain evaluate" $ do
            let trace = mamdaniTrace fanFIS (Map.singleton "temperature" 75.0)
                plain = evaluate fanFIS (Map.singleton "temperature" 75.0)
            traceCrisp trace `shouldBe` plain

        it "input degrees reflect membership at the crisp value" $ do
            let trace = mamdaniTrace fanFIS (Map.singleton "temperature" 75.0)
            case Map.lookup "temperature" (traceInputDegrees trace) of
                Nothing -> expectationFailure "missing temperature in input degrees"
                Just terms -> do
                    Map.lookup "low" terms `shouldBe` Just 0.0
                    Map.lookup "high" terms `shouldBe` Just 0.5

        it "rule strengths align with fisRules order" $ do
            let trace = mamdaniTrace fanFIS (Map.singleton "temperature" 75.0)
            length (traceRuleStrengths trace)
                `shouldBe` length (fisRules fanFIS)

        it "rule strengths are all in [0,1]" $
            property $ \temp' ->
                let temp = clampTo 0 100 (temp' :: Double)
                    trace = mamdaniTrace fanFIS (Map.singleton "temperature" temp)
                 in all (\s -> s >= 0 && s <= 1) (traceRuleStrengths trace)

        it "output curve has samples when any rule fires" $ do
            let trace = mamdaniTrace fanFIS (Map.singleton "temperature" 75.0)
            case Map.lookup "fan" (traceOutputCurves trace) of
                Nothing -> expectationFailure "missing fan in output curves"
                Just curve -> length curve `shouldSatisfy` (> 0)

        it "output curve y-values are all in [0,1]" $ do
            let trace = mamdaniTrace fanFIS (Map.singleton "temperature" 75.0)
            case Map.lookup "fan" (traceOutputCurves trace) of
                Nothing -> expectationFailure "missing fan in output curves"
                Just curve ->
                    all (\(_, y) -> y >= 0 && y <= 1) curve `shouldBe` True

        it "missing crisp input produces no input degrees for that var" $ do
            let trace = mamdaniTrace fanFIS Map.empty
            Map.lookup "temperature" (traceInputDegrees trace) `shouldBe` Nothing

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
