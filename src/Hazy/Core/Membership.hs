module Hazy.Core.Membership (
    triangular,
    trapezoidal,
    gaussian,
    sigmoid,
) where

import Hazy.Core.Types (MembershipFn)

triangular :: Double -> Double -> Double -> MembershipFn
triangular a b c x
    | x <= a = 0.0
    | x >= c = 0.0
    | x < b = (x - a) / (b - a)
    | otherwise = (c - x) / (c - b)

trapezoidal :: Double -> Double -> Double -> Double -> MembershipFn
trapezoidal a b c d x
    | x <= a = 0.0
    | x >= d = 0.0
    | x >= b && x <= c = 1.0
    | x < b = (x - a) / (b - a)
    | otherwise = (d - x) / (d - c)

gaussian :: Double -> Double -> MembershipFn
gaussian mu sigma x =
    exp (-(((x - mu) ** 2) / (2 * sigma ** 2)))

sigmoid :: Double -> Double -> MembershipFn
sigmoid center slope x =
    1 / (1 + exp (-(slope * (x - center))))
