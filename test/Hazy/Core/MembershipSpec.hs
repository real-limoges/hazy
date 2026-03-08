module Hazy.Core.MembershipSpec (spec) where

import Test.Hspec
import Test.QuickCheck

import Hazy.Core.Membership

approxEq :: Double -> Double -> Bool
approxEq a b = abs (a - b) < 1e-10

spec :: Spec
spec = do
    describe "triangular" $ do
        it "returns 1.0 at peak" $
            triangular 0 5 10 5 `shouldBe` 1.0

        it "returns 0.0 at left foot" $
            triangular 0 5 10 0 `shouldBe` 0.0

        it "returns 0.0 at right foot" $
            triangular 0 5 10 10 `shouldBe` 0.0

        it "returns 0.5 at left slope midpoint" $
            triangular 0 5 10 2.5 `shouldBe` 0.5

        it "returns 0.5 at right slope midpoint" $
            triangular 0 5 10 7.5 `shouldBe` 0.5

        it "returns 0.0 outside the triangle" $ do
            triangular 0 5 10 (-1) `shouldBe` 0.0
            triangular 0 5 10 11 `shouldBe` 0.0

        it "always returns values in [0, 1]" $
            property $ \x ->
                let d = triangular 0 5 10 x
                in d >= 0.0 && d <= 1.0

    describe "trapezoidal" $ do
        it "returns 1.0 on flat top" $
            trapezoidal 0 3 7 10 5 `shouldBe` 1.0

        it "returns 1.0 at left shoulder" $
            trapezoidal 0 3 7 10 3 `shouldBe` 1.0

        it "returns 1.0 at right shoulder" $
            trapezoidal 0 3 7 10 7 `shouldBe` 1.0

        it "returns 0.0 at left foot" $
            trapezoidal 0 3 7 10 0 `shouldBe` 0.0

        it "returns 0.0 at right foot" $
            trapezoidal 0 3 7 10 10 `shouldBe` 0.0

        it "returns 0.5 on left slope" $
            trapezoidal 0 3 7 10 1.5 `shouldBe` 0.5

        it "always returns values in [0, 1]" $
            property $ \x ->
                let d = trapezoidal 0 3 7 10 x
                in d >= 0.0 && d <= 1.0

    describe "gaussian" $ do
        it "returns 1.0 at center" $
            gaussian 5 2 5 `shouldBe` 1.0

        it "is symmetric around center" $
            property $ forAll (choose (0.0, 10.0)) $ \offset ->
                gaussian 5 2 (5 + offset) `approxEq` gaussian 5 2 (5 - offset)

        it "always returns values in [0, 1]" $
            property $ \x ->
                let d = gaussian 5 2 x
                in d >= 0.0 && d <= 1.0

    describe "sigmoid" $ do
        it "returns 0.5 at inflection point" $
            sigmoid 5 1 5 `shouldBe` 0.5

        it "is monotonically increasing for positive slope" $
            property $ forAll ((,) <$> choose (-100.0, 100.0) <*> choose (-100.0, 100.0)) $ \(a, b) ->
                a <= b ==> sigmoid 5 1 a <= sigmoid 5 1 b + 1e-10

        it "always returns values in [0, 1]" $
            property $ \x ->
                let d = sigmoid 5 1 x
                in d >= 0.0 && d <= 1.0