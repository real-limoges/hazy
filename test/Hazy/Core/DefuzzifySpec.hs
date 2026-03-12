module Hazy.Core.DefuzzifySpec (spec) where

import Test.Hspec
import Test.QuickCheck

import Hazy.Core.Defuzzify (DefuzzMethod (..), defuzzify)
import Hazy.Core.Membership (trapezoidal, triangular)
import Hazy.Core.Types (FuzzySet (..))

mkSet :: (Double, Double) -> (Double -> Double) -> FuzzySet
mkSet universe mf = FuzzySet{fsName = "test", fsMf = mf, fsUniverse = universe}

spec :: Spec
spec = do
    describe "Centroid" $ do
        it "returns center for symmetric triangular MF" $
            let fs = mkSet (0, 10) (triangular 0 5 10)
             in defuzzify Centroid [(fs, 1.0)] `shouldSatisfy` (\v -> abs (v - 5.0) < 0.05)

        it "returns midpoint for uniform membership" $
            let fs = mkSet (0, 10) (const 1.0)
             in defuzzify Centroid [(fs, 1.0)] `shouldSatisfy` (\v -> abs (v - 5.0) < 0.05)

        it "returns universe midpoint when all memberships are zero" $
            let fs = mkSet (0, 10) (const 0.0)
             in defuzzify Centroid [(fs, 1.0)] `shouldBe` 5.0

    describe "Bisector" $ do
        it "returns center for symmetric triangular MF" $
            let fs = mkSet (0, 10) (triangular 0 5 10)
             in defuzzify Bisector [(fs, 1.0)] `shouldSatisfy` (\v -> abs (v - 5.0) < 0.05)

        it "returns midpoint for uniform membership" $
            let fs = mkSet (0, 10) (const 1.0)
             in defuzzify Bisector [(fs, 1.0)] `shouldSatisfy` (\v -> abs (v - 5.0) < 0.15)

    describe "SmallestOfMax" $ do
        it "returns peak of triangular MF" $
            let fs = mkSet (0, 10) (triangular 0 5 10)
             in defuzzify SmallestOfMax [(fs, 1.0)] `shouldSatisfy` (\v -> abs (v - 5.0) < 0.1)

    describe "LargestOfMax" $ do
        it "returns peak of triangular MF" $
            let fs = mkSet (0, 10) (triangular 0 5 10)
             in defuzzify LargestOfMax [(fs, 1.0)] `shouldSatisfy` (\v -> abs (v - 5.0) < 0.1)

    describe "MeanOfMaximum" $ do
        it "returns mean of flat top for trapezoidal MF" $
            let fs = mkSet (0, 10) (trapezoidal 0 3 7 10)
             in defuzzify MeanOfMaximum [(fs, 1.0)] `shouldSatisfy` (\v -> abs (v - 5.0) < 0.1)

    describe "Custom" $ do
        it "uses the provided function" $
            let f _ = 42.0
             in defuzzify (Custom f) [] `shouldBe` 42.0

    describe "empty input" $ do
        it "returns 0.0 for empty list" $
            defuzzify Centroid [] `shouldBe` 0.0

    describe "properties" $ do
        it "defuzzified value lies within universe bounds" $
            property $ \(lo', range') ->
                let lo = lo' :: Double
                    range = abs (range' :: Double) + 1.0
                    hi = lo + range
                    fs = mkSet (lo, hi) (triangular lo ((lo + hi) / 2) hi)
                    result = defuzzify Centroid [(fs, 1.0)]
                 in result >= lo - 0.01 && result <= hi + 0.01

        it "centroid of symmetric MF returns center" $
            property $ \(center', halfWidth') ->
                let center = center' :: Double
                    halfWidth = abs (halfWidth' :: Double) + 1.0
                    lo = center - halfWidth
                    hi = center + halfWidth
                    fs = mkSet (lo, hi) (triangular lo center hi)
                    result = defuzzify Centroid [(fs, 1.0)]
                 in abs (result - center) < 0.1
