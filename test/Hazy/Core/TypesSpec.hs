module Hazy.Core.TypesSpec (spec) where

import Test.Hspec
import Test.QuickCheck

import Hazy.Core.Types

spec :: Spec
spec = do
    describe "clampDegree" $ do
        it "clamps values above 1.0 to 1.0" $
            clampDegree 1.5 `shouldBe` 1.0

        it "clamps values below 0.0 to 0.0" $
            clampDegree (-0.3) `shouldBe` 0.0

        it "leaves values in [0, 1] unchanged" $
            clampDegree 0.5 `shouldBe` 0.5

        it "preserves boundary values" $ do
            clampDegree 0.0 `shouldBe` 0.0
            clampDegree 1.0 `shouldBe` 1.0

        it "always returns a value in [0, 1]" $
            property $ \x ->
                let d = clampDegree x
                 in d >= 0.0 && d <= 1.0

    describe "FuzzySet" $ do
        it "can be constructed and its membership function evaluated" $ do
            let fs =
                    FuzzySet
                        { fsName = "test"
                        , fsMf = \x -> if x > 0 then 1.0 else 0.0
                        , fsUniverse = (0.0, 10.0)
                        }
            fsMf fs 5.0 `shouldBe` 1.0
            fsMf fs (-1.0) `shouldBe` 0.0

        it "stores universe bounds correctly" $ do
            let fs =
                    FuzzySet
                        { fsName = "bounded"
                        , fsMf = const 0.5
                        , fsUniverse = (0.0, 100.0)
                        }
            fsUniverse fs `shouldBe` (0.0, 100.0)
