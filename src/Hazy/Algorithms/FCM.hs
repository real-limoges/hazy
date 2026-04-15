module Hazy.Algorithms.FCM (
    FCMConfig (..),
    FCMResult (..),
    fcm,
    defaultConfig,
) where

import Data.Vector (Vector)
import Hazy.Algorithms.FCM.Internal (initMembership, iterateFCM)
import Hazy.Core.Types (Degree)

data FCMConfig = FCMConfig
    { fcmClusters :: Int
    , fcmFuzziness :: Double
    , fcmEpsilon :: Double
    , fcmMaxIter :: Int
    }
    deriving (Show, Eq)

data FCMResult = FCMResult
    { fcmCenters :: Vector (Vector Double)
    , fcmMembership :: Vector (Vector Degree)
    , fcmIterations :: Int
    }
    deriving (Show)

defaultConfig :: Int -> FCMConfig
defaultConfig c =
    FCMConfig
        { fcmClusters = c
        , fcmFuzziness = 2.0
        , fcmEpsilon = 1e-5
        , fcmMaxIter = 100
        }

fcm :: FCMConfig -> Vector (Vector Double) -> FCMResult
fcm cfg xs =
    let n = length xs
        u0 = initMembership n (fcmClusters cfg)
        (centers, membership, iters) =
            iterateFCM (fcmFuzziness cfg) (fcmEpsilon cfg) (fcmMaxIter cfg) xs u0
     in FCMResult
            { fcmCenters = centers
            , fcmMembership = membership
            , fcmIterations = iters
            }
