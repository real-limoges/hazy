module Hazy.Core.Types
    ( Degree
    , MembershipFn
    , FuzzySet
    , clampDegree )
where

import Data.Text (Text)

clamp :: Ord a => a -> a -> a -> a
clamp minVal maxVal v
    | v < minVal = minVal
    | v > maxVal = maxVal
    | otherwise  = v

-- Degree being a Double function means we don't have
-- to wrap/unwrap it a bunch
type Degree = Double
type MembershipFn = Double -> Degree

clampDegree :: Double -> Degree
clampDegree v = clamp 0.0 1.0 v

-- Fuzzy Sets are just a collection of things
data FuzzySet = FuzzySet
    { fsName :: Text
    , fsMf :: MembershipFn
    , fsUniverse :: (Double, Double)
    }