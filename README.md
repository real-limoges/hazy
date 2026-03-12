# Hazy

A general-purpose fuzzy logic library in Haskell.

The name evokes the soft boundaries of fuzzy logic — where categories blur and overlap, nothing is crisply one thing or another. That's what fuzzy membership captures: the hazy threshold between "tall" and "not tall", between "rested" and "exhausted".

## What This Is

A **fuzzy logic library** — membership functions, fuzzy operators, t-norms/s-norms, Mamdani and Sugeno inference, defuzzification.

## Building

Requires GHC 9.12+ and Cabal 3.14+.

```bash
cabal build
cabal test
```

## Quick Start

```haskell
import Hazy

import Data.Map.Strict qualified as Map

-- Define membership functions for input/output terms
tempCold = FuzzySet "cold" (triangular 0 0 50)    (0, 100)
tempHot  = FuzzySet "hot"  (triangular 50 100 100) (0, 100)
fanLow   = FuzzySet "low"  (trapezoidal 0 0 30 50)     (0, 100)
fanHigh  = FuzzySet "high" (trapezoidal 50 70 100 100)  (0, 100)

-- Build linguistic variables
tempVar = LinguisticVar "temperature"
            (Map.fromList [("cold", tempCold), ("hot", tempHot)])
            (0, 100)
fanVar  = LinguisticVar "fan"
            (Map.fromList [("low", fanLow), ("high", fanHigh)])
            (0, 100)

-- Define rules and the fuzzy inference system
fis = FIS
    { fisName    = "fan_controller"
    , fisInputs  = Map.singleton "temperature" tempVar
    , fisOutputs = Map.singleton "fan" fanVar
    , fisRules   = [ FuzzyRule [("temperature", "cold")] [("fan", "low")]
                   , FuzzyRule [("temperature", "hot")]  [("fan", "high")]
                   ]
    , fisMethod  = Mamdani
    }

-- Run inference: crisp inputs -> crisp outputs
result = evaluate fis (Map.singleton "temperature" 75.0)
-- => Map.fromList [("fan", ~78.8)]
```

## Architecture

The library is organized in two layers:

- **Core** (`Hazy.Core.*`) — Domain-agnostic fuzzy logic: membership functions, t-norms/s-norms, operators, defuzzification.
- **Inference** (`Hazy.Inference.*`) — Mamdani and Sugeno inference engines. Defines linguistic variables, fuzzy rules, and the top-level `evaluate` function.

### Module Structure

```
Hazy                        -- Re-exports everything
├── Hazy.Core               -- Re-exports all Core modules
│   ├── Hazy.Core.Types     -- Degree, MembershipFn, FuzzySet
│   ├── Hazy.Core.Membership-- triangular, trapezoidal, gaussian, sigmoid
│   ├── Hazy.Core.TNorm     -- MinMax, Product, Lukasiewicz
│   ├── Hazy.Core.Operators -- fuzzyAnd, fuzzyOr, fuzzyNot, very, somewhat
│   └── Hazy.Core.Defuzzify -- Centroid, Bisector, MeanOfMaximum, ...
└── Hazy.Inference          -- Re-exports Types + Evaluate
    ├── Hazy.Inference.Types-- LinguisticVar, FuzzyRule, FIS
    └── Hazy.Inference.Evaluate -- evaluate
```

Mamdani and Sugeno engines are internal modules, dispatched through `evaluate`.

See [`docs/architecture.md`](docs/architecture.md) for the full design document.

### Key Design Decisions

- **Purity**: `evaluate :: FIS -> Map Text Double -> Map Text Double` is pure — no IO, no state.
- **Membership functions are just functions**: `type MembershipFn = Double -> Degree`. No wrapper types.
- **Extensible aggregation**: T-norms/S-norms use typeclasses (`TNorm`, `SNorm`), so users can define their own.
- **Extensible defuzzification**: The `Custom` constructor accepts any `[(FuzzySet, Degree)] -> Double`.

## References

- Zadeh, L.A. (1965). *Fuzzy Sets*. Information and Control, 8(3), 338-353.
- Ross, T.J. *Fuzzy Logic with Engineering Applications*.
- Klir, G.J. & Yuan, B. *Fuzzy Sets and Fuzzy Logic: Theory and Applications*.

## License

BSD-3-Clause
