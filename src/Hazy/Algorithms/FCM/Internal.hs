module Hazy.Algorithms.FCM.Internal (
    initMembership,
    updateCenters,
    updateMembership,
    distance,
    converged,
    iterateFCM,
) where

import Data.Vector (Vector)
import Data.Vector qualified as V
import Hazy.Core.Types (Degree)

initMembership :: Int -> Int -> Vector (Vector Degree)
initMembership n c = V.generate n $ \i ->
    let raw = V.generate c $ \j ->
            1.0 + 0.1 * sin (fromIntegral (i * 7 + j * 13))
        s = V.sum raw
     in V.map (/ s) raw

updateCenters :: Double -> Vector (Vector Degree) -> Vector (Vector Double) -> Vector (Vector Double)
updateCenters m u xs = V.generate c $ \i ->
    let weights = V.map (\uj -> uj `V.unsafeIndex` i ** m) u
        totalW = V.sum weights
        dims = V.length (V.head xs)
     in V.generate dims $ \d ->
            V.sum (V.zipWith (\w x -> w * (x `V.unsafeIndex` d)) weights xs) / totalW
  where
    c = V.length (V.head u)

updateMembership :: Double -> Vector (Vector Double) -> Vector (Vector Double) -> Vector (Vector Degree)
updateMembership m centers xs = V.map (pointMembership centers) xs
  where
    exp' = 2.0 / (m - 1.0)
    c = V.length centers

    pointMembership cs x =
        let dists = V.map (distance x) cs
         in if V.any (== 0) dists
                then V.generate c $ \i -> if dists `V.unsafeIndex` i == 0 then 1.0 else 0.0
                else V.generate c $ \i ->
                    let di = dists `V.unsafeIndex` i
                     in 1.0 / V.sum (V.map (\dk -> (di / dk) ** exp') dists)

distance :: Vector Double -> Vector Double -> Double
distance a b = sqrt $ V.sum $ V.zipWith (\x y -> (x - y) ** 2) a b

converged :: Double -> Vector (Vector Degree) -> Vector (Vector Degree) -> Bool
converged eps old new' = maxDiff < eps
  where
    maxDiff = V.maximum $ V.zipWith (\r1 r2 -> V.maximum $ V.zipWith (\a b -> abs (a - b)) r1 r2) old new'

iterateFCM :: Double -> Double -> Int -> Vector (Vector Double) -> Vector (Vector Degree) -> (Vector (Vector Double), Vector (Vector Degree), Int)
iterateFCM m eps maxIter xs = go 0
  where
    go iter u
        | iter >= maxIter = (centers, u, iter)
        | converged eps u u' = (centers, u', iter + 1)
        | otherwise = go (iter + 1) u'
      where
        centers = updateCenters m u xs
        u' = updateMembership m centers xs
