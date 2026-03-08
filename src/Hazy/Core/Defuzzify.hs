module Hazy.Core.Defuzzify
    ( DefuzzMethod(..)
    , defuzzify
    ) where

import Hazy.Core.Types (FuzzySet, Degree)

data DefuzzMethod
    = Centroid
    | Bisector
    | MeanOfMaximum
    | SmallestOfMax
    | LargestOfMax
    | Custom ([(FuzzySet, Degree)] -> Double)

defuzzify :: DefuzzMethod -> [(FuzzySet, Degree)] -> Double
defuzzify Centroid fss = undefined
defuzzify Bisector fss = undefined
defuzzify MeanOfMaximum fss = undefined
defuzzify SmallestOfMax fss = undefined
defuzzify LargestOfMax fss = undefined
defuzzify (Custom f) fss = f fss