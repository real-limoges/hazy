module Hazy.Inference.Evaluate (
    evaluate,
    mamdaniTrace,
) where

import Data.Map.Strict (Map)
import Data.Text (Text)

import Hazy.Inference.Mamdani (mamdani, mamdaniTrace)
import Hazy.Inference.Sugeno (sugeno)
import Hazy.Inference.Types (FIS (..), InferenceMethod (..))

evaluate :: FIS -> Map Text Double -> Map Text Double
evaluate fis inputs = case fisMethod fis of
    Mamdani -> mamdani fis inputs
    Sugeno -> sugeno fis inputs
