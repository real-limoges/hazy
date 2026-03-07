module Liminal.Core.Operators
where


fuzzyAnd :: TNorm t => t -> FuzzySet -> FuzzySet -> FuzzySet

fuzzyOr :: TNorm t => t -> FuzzySet -> FuzzySet -> FuzzySet

fuzzyNot :: FuzzySet -> FuzzySet

very :: FuzzySet -> FuzzySet

somewhat :: FuzzySet -> FuzzySet