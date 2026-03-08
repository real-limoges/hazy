module Hazy.Inference.Sugeno
where

import Data.Text (Text)
import Hazy.Inference.Types (FIS)

sugeno :: FIS -> Map Text Double -> Map Text Double
sugeno fis