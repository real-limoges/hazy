module Hazy.Core.Types (
    Degree,
    MembershipFn,
    FuzzySet (..),
    clampDegree,
)
where

import Data.Text (Text)

clamp :: (Ord a) => a -> a -> a -> a
clamp lo hi v
    | v < lo = lo
    | v > hi = hi
    | otherwise = v

type Degree = Double
type MembershipFn = Double -> Degree

clampDegree :: Double -> Degree
clampDegree = clamp 0.0 1.0

data FuzzySet = FuzzySet
    { fsName :: Text
    , fsMf :: MembershipFn
    , fsUniverse :: (Double, Double)
    }
