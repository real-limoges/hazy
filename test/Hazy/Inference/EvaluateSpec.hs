module Hazy.Inference.EvaluateSpec (spec) where

import Data.Map.Strict qualified as Map
import Test.Hspec

import Hazy.Core.Membership (trapezoidal, triangular)
import Hazy.Core.Types (FuzzySet (..))
import Hazy.Inference.Evaluate (evaluate)
import Hazy.Inference.Types

spec :: Spec
spec = do
    describe "evaluate" $ do
        it "produces output when fisMethod is Mamdani" $ do
            let inputs = Map.singleton "temperature" 75.0
                result = evaluate (fanFIS Mamdani) inputs
            Map.member "fan" result `shouldBe` True

        it "produces output when fisMethod is Sugeno" $ do
            let inputs = Map.singleton "temperature" 75.0
                result = evaluate (fanFIS Sugeno) inputs
            Map.member "fan" result `shouldBe` True

        it "same FIS with different methods produces output for both" $ do
            let inputs = Map.singleton "temperature" 75.0
                mamdaniResult = evaluate (fanFIS Mamdani) inputs
                sugenoResult = evaluate (fanFIS Sugeno) inputs
            Map.member "fan" mamdaniResult `shouldBe` True
            Map.member "fan" sugenoResult `shouldBe` True

fanFIS :: InferenceMethod -> FIS
fanFIS method =
    FIS
        { fisName = "fan_controller"
        , fisInputs = Map.singleton "temperature" tempVar
        , fisOutputs = Map.singleton "fan" fanVar
        , fisRules = [rule1, rule2]
        , fisMethod = method
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
