module Hazy.Core.Norm
where

import Hazy.Core.Types (Degree)

class TNorm t where
    tnorm :: t -> Degree -> Degree -> Degree

class SNorm s where
    snorm :: s -> Degree -> Degree -> Degree


data MinMax = MinMax
data Product = Product
data Lukasiewicz = Lukasiewicz

instance TNorm MinMax where tnorm _ a b = min a b
instance SNorm MinMax where snorm _ a b = max a b

instance TNorm Product where tnorm _ a b = a * b
instance SNorm Product where snorm _ a b = a + b - a * b

instance TNorm Lukasiewicz where tnorm _ a b = max 0.0 (a + b - 1)
instance SNorm Lukasiewicz where snorm _ a b = min 1.0 (a + b)