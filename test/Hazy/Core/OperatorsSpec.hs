module Hazy.Core.OperatorsSpec (spec) where

import Test.Hspec
import Test.QuickCheck

import Hazy.Core.Types
import Hazy.Core.TNorm (MinMax(..))
import Hazy.Core.Operators

approxEq :: Double -> Double -> Bool
approxEq a b = abs (a - b) < 1e-10

constSet :: Double -> FuzzySet
constSet d = FuzzySet
    { fsName = ""
    , fsMf = const d
    , fsUniverse = (0.0, 10.0)
    }

spec :: Spec
spec = do
    describe "fuzzyNot" $ do
        it "complements: mu=0.7 -> 0.3" $ do
            let fs = constSet 0.7
            fsMf (fuzzyNot fs) 5.0 `approxEq` 0.3 `shouldBe` True

        it "complements: mu=0.0 -> 1.0" $ do
            let fs = constSet 0.0
            fsMf (fuzzyNot fs) 5.0 `approxEq` 1.0 `shouldBe` True

        it "double negation restores original" $
            property $ forAll (choose (0.0, 1.0)) $ \d ->
                let fs = constSet d
                    result = fsMf (fuzzyNot (fuzzyNot fs)) 5.0
                in result `approxEq` d

    describe "very" $ do
        it "concentrates: mu=0.5 -> 0.25" $ do
            let fs = constSet 0.5
            fsMf (very fs) 5.0 `approxEq` 0.25 `shouldBe` True

        it "produces values <= original for degrees in [0, 1]" $
            property $ forAll (choose (0.0, 1.0)) $ \d ->
                let fs = constSet d
                in fsMf (very fs) 5.0 <= d + 1e-10

    describe "somewhat" $ do
        it "dilates: mu=0.25 -> 0.5" $ do
            let fs = constSet 0.25
            fsMf (somewhat fs) 5.0 `approxEq` 0.5 `shouldBe` True

        it "produces values >= original for degrees in [0, 1]" $
            property $ forAll (choose (0.0, 1.0)) $ \d ->
                let fs = constSet d
                in fsMf (somewhat fs) 5.0 >= d - 1e-10

    describe "fuzzyAnd" $ do
        it "AND result <= min of inputs" $
            property $ forAll ((,) <$> choose (0.0, 1.0) <*> choose (0.0, 1.0)) $ \(d1, d2) ->
                let a = constSet d1
                    b = constSet d2
                    result = fsMf (fuzzyAnd MinMax a b) 5.0
                in result <= min d1 d2 + 1e-10

        it "computes universe as intersection" $ do
            let a = FuzzySet { fsName = "", fsMf = const 0.5, fsUniverse = (0.0, 10.0) }
                b = FuzzySet { fsName = "", fsMf = const 0.5, fsUniverse = (2.0, 8.0) }
            fsUniverse (fuzzyAnd MinMax a b) `shouldBe` (2.0, 8.0)

    describe "fuzzyOr" $ do
        it "OR result >= max of inputs" $
            property $ forAll ((,) <$> choose (0.0, 1.0) <*> choose (0.0, 1.0)) $ \(d1, d2) ->
                let a = constSet d1
                    b = constSet d2
                    result = fsMf (fuzzyOr MinMax a b) 5.0
                in result >= max d1 d2 - 1e-10