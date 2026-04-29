# Architecture

This document describes the design of Hazy, a general-purpose fuzzy logic library in Haskell.

## Layers

Hazy is organized in three layers, each strictly above the previous:

1. **Core** (`Hazy.Core.*`) — Domain-agnostic fuzzy primitives. No notion of rules, variables, or inference.
2. **Inference** (`Hazy.Inference.*`) — Mamdani and Sugeno fuzzy inference systems built on Core.
3. **Algorithms** (`Hazy.Algorithms.*`) — Fuzzy clustering and other higher-level algorithms built on Core.

`Hazy` is the umbrella module and re-exports the public surfaces of all three.

## Core

### `Hazy.Core.Types`

- `Degree` — a `Double` constrained to `[0, 1]`. Used for membership values throughout.
- `MembershipFn = Double -> Degree` — a plain function alias. Avoiding a wrapper newtype keeps composition trivial.
- `FuzzySet` — a named membership function over a universe interval `(Double, Double)`.

### `Hazy.Core.Membership`

Standard membership-function constructors: `triangular`, `trapezoidal`, `gaussian`, `sigmoid`. Each returns a `MembershipFn`.

### `Hazy.Core.TNorm`

`TNorm` and `SNorm` typeclasses with a single binary combinator each. Built-in instances:

- `MinMax` — Zadeh's classical operators (`min` / `max`).
- `Product` — algebraic product / probabilistic sum.
- `Lukasiewicz` — bounded-difference / bounded-sum.

Users can add their own instance by writing a one-method newtype, with no further wiring.

### `Hazy.Core.Operators`

Composable fuzzy combinators built on the chosen t-norm: `fuzzyAnd`, `fuzzyOr`, `fuzzyNot`, plus the linguistic hedges `very` and `somewhat`.

### `Hazy.Core.Defuzzify`

`DefuzzMethod` is a sum type: `Centroid`, `Bisector`, `MeanOfMaximum`, `SmallestOfMaximum`, `LargestOfMaximum`, and `Custom ([(FuzzySet, Degree)] -> Double)`. The `defuzzify` function dispatches over the constructor. The `Custom` escape hatch keeps the type closed without sacrificing extensibility.

## Inference

### `Hazy.Inference.Types`

- `LinguisticVar` — a named variable with a map of term names to `FuzzySet`s and a universe interval.
- `FuzzyRule` — antecedent and consequent expressed as `[(varName, termName)]` pairs.
- `InferenceMethod` — `Mamdani` or `Sugeno`.
- `FIS` — the bundle: name, input/output variables, rules, and method.

### `Hazy.Inference.Evaluate`

The single public entry point:

```haskell
evaluate :: FIS -> Map Text Double -> Map Text Double
```

Pure: crisp inputs in, crisp outputs out, no IO and no state. Internally dispatches to one of two **internal** modules:

- `Hazy.Inference.Mamdani` — implication via t-norm clipping, aggregation across rules, defuzzification per output variable.
- `Hazy.Inference.Sugeno` — weighted-average defuzzification over rule activations.

Neither internal module is `exposed-modules`. Library consumers cannot import them. This keeps the inference contract narrow and lets the engines evolve independently.

## Algorithms

### `Hazy.Algorithms.FCM`

Fuzzy C-Means clustering. The public surface is small:

- `FCMConfig { fcmClusters, fcmFuzziness, fcmEpsilon, fcmMaxIter }`
- `FCMResult { fcmCenters, fcmMembership, fcmIterations }`
- `defaultConfig :: Int -> FCMConfig` — fuzziness 2.0, epsilon 1e-5, 100-iteration cap.
- `fcm :: FCMConfig -> Vector (Vector Double) -> FCMResult`

`fcm` is **deterministic**: initial membership is seeded by a fixed sinusoidal pattern (no RNG, no IO). This makes results reproducible across runs and easy to test.

### `Hazy.Algorithms.FCM.Internal`

Internal numerical kernels: `initMembership`, `updateCenters`, `updateMembership`, `distance`, `converged`, `iterateFCM`. Marked `other-modules` so they are not part of the public API.

## Design Principles

- **Purity first.** Every public function is pure. There is no global state, no randomness, and no IO anywhere in the library. This makes equational reasoning, property-based testing, and parallel use trivial.
- **Plain functions over wrappers.** `MembershipFn` is a type synonym, not a newtype, so users can compose, hedge, and transform membership without ceremony.
- **Typeclasses for axiom-driven extensibility.** `TNorm`/`SNorm` are the right abstraction because the laws (commutativity, associativity, monotonicity, identity) constrain implementations meaningfully.
- **Closed sums with a `Custom` escape.** `DefuzzMethod` is a sum type so the standard methods get pattern-matched dispatch, but `Custom` lets advanced users plug in arbitrary defuzzifiers without forking.
- **Public surface narrow, internals private.** Mamdani, Sugeno, and FCM internals are `other-modules`. Consumers go through `evaluate` and `fcm`. This is enforced by the Cabal build.

## Testing Strategy

- **Property-based** (QuickCheck) for fuzzy logic axioms: t-norm laws, membership-function bounds, defuzzification within universe bounds.
- **Known-answer** for membership functions (e.g., `triangular 0 5 10` at `x = 5` returns `1.0`).
- **Integration** tests through `evaluate` for the full inference pipeline.
- **Convergence** tests for FCM: partition-of-unity (memberships sum to 1), monotone decrease of the objective, bounded iteration count.
- Tests import only the public API. They never reach into Mamdani, Sugeno, or `FCM.Internal`.

## Build & Toolchain

- GHC2024 language standard.
- `-Wall -O2` enabled globally via the `common warnings` stanza in `hazy.cabal`.
- `base >=4.21 && <4.23`.
- `cabal-version: 3.14`.
- Dependencies: `text`, `containers` (`Data.Map.Strict` for variable maps), `vector` (FCM kernels). Tests additionally use `hspec` and `QuickCheck`.
