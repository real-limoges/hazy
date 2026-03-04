module Liminal.Core.Defuzzify
where

data DefuzzMethod
    = Centroid
    | Bisector
    | MeanOfMaximum
    | SmallestOfMax
    | LargestOfMax