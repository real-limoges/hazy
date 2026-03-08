module Hazy.Core.Operators
where

import Hazy.Core.Types (FuzzySet(..))
import Hazy.Core.TNorm (TNorm(tnorm), SNorm(snorm))

fuzzyAnd :: TNorm t => t -> FuzzySet -> FuzzySet -> FuzzySet
fuzzyAnd t a b = FuzzySet
    { fsName = (fsName a) <> "__AND__" <> (fsName b)
    , fsMf = \x -> tnorm t (fsMf a x) (fsMf b x)
    , fsUniverse = (max lo1 lo2, min hi1 hi2)
    }
  where
    (lo1, hi1) = fsUniverse a
    (lo2, hi2) = fsUniverse b


fuzzyOr :: SNorm s => s -> FuzzySet -> FuzzySet -> FuzzySet
fuzzyOr s a b = FuzzySet
    { fsName = (fsName a) <> "__OR__" <> (fsName b)
    , fsMf = \x -> snorm s (fsMf a x) (fsMf b x)
    , fsUniverse = (max lo1 lo2, min hi1 hi2)
    }
  where
    (lo1, hi1) = fsUniverse a
    (lo2, hi2) = fsUniverse b

fuzzyNot :: FuzzySet -> FuzzySet
fuzzyNot fs = fs { fsMf = (1 -) . (fsMf fs) }

very :: FuzzySet -> FuzzySet
very fs = fs { fsMf = (^ 2) . (fsMf fs) }

somewhat :: FuzzySet -> FuzzySet
somewhat fs = fs { fsMf = sqrt . fsMf fs }