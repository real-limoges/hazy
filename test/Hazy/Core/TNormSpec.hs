module Hazy.Core.TNormSpec (spec) where

import Test.Hspec
import Test.QuickCheck

import Hazy.Core.TNorm

-- Generator for values in [0, 1]
degree :: Gen Double
degree = choose (0.0, 1.0)

approxEq :: Double -> Double -> Bool
approxEq a b = abs (a - b) < 1e-10

spec :: Spec
spec = do
    describe "TNorm MinMax" $ do
        it "known-answer: tnorm MinMax 0.3 0.7 == 0.3" $
            tnorm MinMax 0.3 0.7 `shouldBe` 0.3

        it "commutativity" $
            property $
                forAll ((,) <$> degree <*> degree) $ \(a, b) ->
                    tnorm MinMax a b `shouldBe` tnorm MinMax b a

        it "identity: tnorm t a 1.0 == a" $
            property $
                forAll degree $ \a ->
                    tnorm MinMax a 1.0 `approxEq` a

        it "monotonicity" $
            property $
                forAll ((,,) <$> degree <*> degree <*> degree) $ \(a, b, c) ->
                    a <= b ==> tnorm MinMax a c <= tnorm MinMax b c

        it "result in [0, 1]" $
            property $
                forAll ((,) <$> degree <*> degree) $ \(a, b) ->
                    let r = tnorm MinMax a b in r >= 0.0 && r <= 1.0

    describe "SNorm MinMax" $ do
        it "known-answer: snorm MinMax 0.3 0.7 == 0.7" $
            snorm MinMax 0.3 0.7 `shouldBe` 0.7

        it "commutativity" $
            property $
                forAll ((,) <$> degree <*> degree) $ \(a, b) ->
                    snorm MinMax a b `shouldBe` snorm MinMax b a

        it "identity: snorm s a 0.0 == a" $
            property $
                forAll degree $ \a ->
                    snorm MinMax a 0.0 `approxEq` a

        it "result in [0, 1]" $
            property $
                forAll ((,) <$> degree <*> degree) $ \(a, b) ->
                    let r = snorm MinMax a b in r >= 0.0 && r <= 1.0

    describe "TNorm Product" $ do
        it "known-answer: tnorm Product 0.5 0.5 == 0.25" $
            tnorm Product 0.5 0.5 `shouldBe` 0.25

        it "commutativity" $
            property $
                forAll ((,) <$> degree <*> degree) $ \(a, b) ->
                    tnorm Product a b `approxEq` tnorm Product b a

        it "identity: tnorm t a 1.0 == a" $
            property $
                forAll degree $ \a ->
                    tnorm Product a 1.0 `approxEq` a

        it "monotonicity" $
            property $
                forAll ((,,) <$> degree <*> degree <*> degree) $ \(a, b, c) ->
                    a <= b ==> tnorm Product a c <= tnorm Product b c + 1e-10

        it "result in [0, 1]" $
            property $
                forAll ((,) <$> degree <*> degree) $ \(a, b) ->
                    let r = tnorm Product a b in r >= 0.0 && r <= 1.0

    describe "SNorm Product" $ do
        it "known-answer: snorm Product 0.5 0.5 == 0.75" $
            snorm Product 0.5 0.5 `shouldBe` 0.75

        it "commutativity" $
            property $
                forAll ((,) <$> degree <*> degree) $ \(a, b) ->
                    snorm Product a b `approxEq` snorm Product b a

        it "identity: snorm s a 0.0 == a" $
            property $
                forAll degree $ \a ->
                    snorm Product a 0.0 `approxEq` a

        it "result in [0, 1]" $
            property $
                forAll ((,) <$> degree <*> degree) $ \(a, b) ->
                    let r = snorm Product a b in r >= 0.0 && r <= 1.0

    describe "TNorm Lukasiewicz" $ do
        it "known-answer: tnorm Lukasiewicz 0.6 0.7 == 0.3" $
            tnorm Lukasiewicz 0.6 0.7 `approxEq` 0.3 `shouldBe` True

        it "commutativity" $
            property $
                forAll ((,) <$> degree <*> degree) $ \(a, b) ->
                    tnorm Lukasiewicz a b `approxEq` tnorm Lukasiewicz b a

        it "identity: tnorm t a 1.0 == a" $
            property $
                forAll degree $ \a ->
                    tnorm Lukasiewicz a 1.0 `approxEq` a

        it "monotonicity" $
            property $
                forAll ((,,) <$> degree <*> degree <*> degree) $ \(a, b, c) ->
                    a <= b ==> tnorm Lukasiewicz a c <= tnorm Lukasiewicz b c + 1e-10

        it "result in [0, 1]" $
            property $
                forAll ((,) <$> degree <*> degree) $ \(a, b) ->
                    let r = tnorm Lukasiewicz a b in r >= 0.0 && r <= 1.0

    describe "SNorm Lukasiewicz" $ do
        it "known-answer: snorm Lukasiewicz 0.6 0.7 == 1.0" $
            snorm Lukasiewicz 0.6 0.7 `shouldBe` 1.0

        it "commutativity" $
            property $
                forAll ((,) <$> degree <*> degree) $ \(a, b) ->
                    snorm Lukasiewicz a b `approxEq` snorm Lukasiewicz b a

        it "identity: snorm s a 0.0 == a" $
            property $
                forAll degree $ \a ->
                    snorm Lukasiewicz a 0.0 `approxEq` a

        it "result in [0, 1]" $
            property $
                forAll ((,) <$> degree <*> degree) $ \(a, b) ->
                    let r = snorm Lukasiewicz a b in r >= 0.0 && r <= 1.0
