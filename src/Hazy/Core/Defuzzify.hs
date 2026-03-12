module Hazy.Core.Defuzzify (
    DefuzzMethod (..),
    defuzzify,
) where

import Hazy.Core.Types (Degree, FuzzySet (..))

data DefuzzMethod
    = Centroid
    | Bisector
    | MeanOfMaximum
    | SmallestOfMax
    | LargestOfMax
    | Custom ([(FuzzySet, Degree)] -> Double)

defaultResolution :: Int
defaultResolution = 200

samplePoints :: Int -> (Double, Double) -> [Double]
samplePoints n (lo, hi) = [lo + fromIntegral i * step | i <- [0 .. n - 1]]
  where
    step = (hi - lo) / fromIntegral (n - 1)

combinedUniverse :: [(FuzzySet, Degree)] -> (Double, Double)
combinedUniverse fss = (minimum los, maximum his)
  where
    (los, his) = unzip [fsUniverse fs | (fs, _) <- fss]

aggregatedMf :: [(FuzzySet, Degree)] -> Double -> Degree
aggregatedMf fss x = maximum [min alpha (fsMf fs x) | (fs, alpha) <- fss]

defuzzify :: DefuzzMethod -> [(FuzzySet, Degree)] -> Double
defuzzify (Custom f) fss = f fss
defuzzify _ [] = 0.0
defuzzify method fss =
    let (lo, hi) = combinedUniverse fss
        xs = samplePoints defaultResolution (lo, hi)
        mu = aggregatedMf fss
        vals = [(x, mu x) | x <- xs]
     in case method of
            Centroid ->
                let num = sum [x * m | (x, m) <- vals]
                    den = sum [m | (_, m) <- vals]
                 in if den == 0 then (lo + hi) / 2 else num / den
            Bisector ->
                let totalArea = sum [m | (_, m) <- vals]
                 in if totalArea == 0
                        then (lo + hi) / 2
                        else bisect vals (totalArea / 2)
            SmallestOfMax ->
                let maxMu = maximum (map snd vals)
                 in if maxMu == 0
                        then (lo + hi) / 2
                        else case filter (\(_, m) -> m == maxMu) vals of
                            ((v, _) : _) -> v
                            [] -> (lo + hi) / 2
            LargestOfMax ->
                let maxMu = maximum (map snd vals)
                 in if maxMu == 0
                        then (lo + hi) / 2
                        else fst (last (filter (\(_, m) -> m == maxMu) vals))
            MeanOfMaximum ->
                let maxMu = maximum (map snd vals)
                 in if maxMu == 0
                        then (lo + hi) / 2
                        else
                            let maxPts = [x | (x, m) <- vals, m == maxMu]
                             in sum maxPts / fromIntegral (length maxPts)

bisect :: [(Double, Double)] -> Double -> Double
bisect [] _ = 0.0
bisect [(x, _)] _ = x
bisect ((x, m) : rest) remaining
    | remaining <= m = x
    | otherwise = bisect rest (remaining - m)
