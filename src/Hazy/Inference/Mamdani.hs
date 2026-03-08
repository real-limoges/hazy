module Hazy.Inference.Mamdani
where

import Data.Text (Text)
import Hazy.Core.Types (clampDegree)
import Hazy.Inference.Types (FIS)


mamdani :: FIS -> Map Text Double -> Map Text Double
mamdani fis data =
    let