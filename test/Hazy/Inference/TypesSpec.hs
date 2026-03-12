module Hazy.Inference.TypesSpec (spec) where

import Data.Map.Strict qualified as Map
import Test.Hspec

import Hazy.Core.Membership (trapezoidal, triangular)
import Hazy.Core.Types (FuzzySet (..))
import Hazy.Inference.Types

spec :: Spec
spec = do
    describe "LinguisticVar" $ do
        it "can be constructed with a map of terms" $ do
            let low = FuzzySet "low" (triangular 0 0 5) (0, 10)
                high = FuzzySet "high" (triangular 5 10 10) (0, 10)
                lv =
                    LinguisticVar
                        { lvName = "temperature"
                        , lvTerms = Map.fromList [("low", low), ("high", high)]
                        , lvBounds = (0, 10)
                        }
            lvName lv `shouldBe` "temperature"
            Map.size (lvTerms lv) `shouldBe` 2
            Map.member "low" (lvTerms lv) `shouldBe` True
            Map.member "high" (lvTerms lv) `shouldBe` True

        it "stores universe bounds correctly" $ do
            let lv =
                    LinguisticVar
                        { lvName = "pressure"
                        , lvTerms = Map.empty
                        , lvBounds = (0, 100)
                        }
            lvBounds lv `shouldBe` (0, 100)

    describe "FuzzyRule" $ do
        it "can be constructed and its antecedents inspected" $ do
            let rule =
                    FuzzyRule
                        { ruleAntecedent = [("temperature", "high"), ("pressure", "low")]
                        , ruleConsequent = [("valve", "open")]
                        }
            length (ruleAntecedent rule) `shouldBe` 2
            ruleAntecedent rule `shouldBe` [("temperature", "high"), ("pressure", "low")]

        it "can be constructed and its consequents inspected" $ do
            let rule =
                    FuzzyRule
                        { ruleAntecedent = [("speed", "fast")]
                        , ruleConsequent = [("brake", "hard"), ("throttle", "off")]
                        }
            length (ruleConsequent rule) `shouldBe` 2

    describe "FIS" $ do
        it "can be constructed with inputs, outputs, and rules" $ do
            let tempLow = FuzzySet "low" (triangular 0 0 50) (0, 100)
                tempHigh = FuzzySet "high" (triangular 50 100 100) (0, 100)
                fanOff = FuzzySet "off" (trapezoidal 0 0 30 50) (0, 100)
                fanOn = FuzzySet "on" (trapezoidal 50 70 100 100) (0, 100)
                tempVar =
                    LinguisticVar
                        { lvName = "temperature"
                        , lvTerms = Map.fromList [("low", tempLow), ("high", tempHigh)]
                        , lvBounds = (0, 100)
                        }
                fanVar =
                    LinguisticVar
                        { lvName = "fan"
                        , lvTerms = Map.fromList [("off", fanOff), ("on", fanOn)]
                        , lvBounds = (0, 100)
                        }
                rule1 = FuzzyRule [("temperature", "low")] [("fan", "off")]
                rule2 = FuzzyRule [("temperature", "high")] [("fan", "on")]
                fis =
                    FIS
                        { fisName = "fan_controller"
                        , fisInputs = Map.fromList [("temperature", tempVar)]
                        , fisOutputs = Map.fromList [("fan", fanVar)]
                        , fisRules = [rule1, rule2]
                        , fisMethod = Mamdani
                        }
            fisName fis `shouldBe` "fan_controller"
            Map.size (fisInputs fis) `shouldBe` 1
            Map.size (fisOutputs fis) `shouldBe` 1
            length (fisRules fis) `shouldBe` 2
            fisMethod fis `shouldBe` Mamdani

        it "round-trip: components match what was provided" $ do
            let fs = FuzzySet "medium" (triangular 3 5 7) (0, 10)
                lv = LinguisticVar "x" (Map.singleton "medium" fs) (0, 10)
                rule = FuzzyRule [("x", "medium")] [("x", "medium")]
                fis = FIS "echo" (Map.singleton "x" lv) (Map.singleton "x" lv) [rule] Sugeno
            fisMethod fis `shouldBe` Sugeno
            Map.member "x" (fisInputs fis) `shouldBe` True
            Map.member "x" (fisOutputs fis) `shouldBe` True
            case Map.lookup "x" (fisInputs fis) of
                Just lv' -> lvName lv' `shouldBe` "x"
                Nothing -> expectationFailure "input 'x' not found"
            fisRules fis `shouldBe` [rule]
