module Hazy.Algorithms.FCMSpec (spec) where

import Data.Vector (Vector)
import Data.Vector qualified as V
import Hazy.Algorithms.FCM
import Test.Hspec
import Test.Hspec.QuickCheck (prop)
import Test.QuickCheck

twoClusterData :: Vector (Vector Double)
twoClusterData = V.fromList $ map (V.singleton) [1, 2, 3, 10, 11, 12]

spec :: Spec
spec = describe "Hazy.Algorithms.FCM" $ do
    let cfg = defaultConfig 2
        result = fcm cfg twoClusterData

    describe "known-answer: two well-separated 1D clusters" $ do
        it "finds two centers" $
            V.length (fcmCenters result) `shouldBe` 2

        it "centers are near 2 and 11" $ do
            let cs = V.toList $ V.map V.head (fcmCenters result)
                (lo, hi) = case cs of
                    [a, b] | a <= b -> (a, b)
                           | otherwise -> (b, a)
                    _ -> error "expected 2 centers"
            lo `shouldSatisfy` (\x -> abs (x - 2.0) < 0.5)
            hi `shouldSatisfy` (\x -> abs (x - 11.0) < 0.5)

        it "high membership for closest cluster" $ do
            let row0 = fcmMembership result `V.unsafeIndex` 0
                maxU = V.maximum row0
            maxU `shouldSatisfy` (> 0.9)

    describe "properties" $ do
        it "all degrees in [0,1]" $ do
            let allDegrees = concatMap V.toList (V.toList (fcmMembership result))
            all (\d -> d >= 0 && d <= 1) allDegrees `shouldBe` True

        it "rows sum to ~1.0" $ do
            let sums = V.toList $ V.map V.sum (fcmMembership result)
            all (\s -> abs (s - 1.0) < 1e-9) sums `shouldBe` True

        it "iterations <= maxIter" $
            fcmIterations result `shouldSatisfy` (<= fcmMaxIter cfg)

        prop "degrees bounded for random data" $ \(Positive n') ->
            let n = min n' 20
                xs = V.generate n (\i -> V.singleton (fromIntegral i :: Double))
                r = fcm (defaultConfig 2) xs
             in all (\row -> all (\d -> d >= 0 && d <= 1) (V.toList row))
                    (V.toList (fcmMembership r))
