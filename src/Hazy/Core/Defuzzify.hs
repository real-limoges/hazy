module Hazy.Core.Defuzzify
where

data DefuzzMethod
    = Centroid
    | Bisector
    | MeanOfMaximum
    | SmallestOfMax
    | LargestOfMax