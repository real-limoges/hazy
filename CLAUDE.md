# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Hazy is a general-purpose fuzzy logic library in Haskell. The library provides membership functions, fuzzy operators, t-norms/s-norms, Mamdani and Sugeno inference, and defuzzification.

## Build & Development Commands

```bash
cabal build              # Build the project
cabal test               # Run the test suite
cabal clean              # Clean build artifacts
```

## Architecture

The codebase follows a layered architecture. Full architecture details are in `docs/architecture.md`.

### Module Hierarchy

```
Hazy                          -- Top-level re-export
├── Hazy.Core                 -- Re-exports all Core modules
│   ├── Hazy.Core.Types       -- Degree, MembershipFn, FuzzySet
│   ├── Hazy.Core.Membership  -- triangular, trapezoidal, gaussian, sigmoid
│   ├── Hazy.Core.TNorm       -- TNorm/SNorm typeclasses; MinMax, Product, Lukasiewicz
│   ├── Hazy.Core.Operators   -- fuzzyAnd, fuzzyOr, fuzzyNot, very, somewhat
│   └── Hazy.Core.Defuzzify   -- DefuzzMethod (Centroid, Bisector, ..., Custom), defuzzify
└── Hazy.Inference            -- Re-exports Types + Evaluate
    ├── Hazy.Inference.Types  -- LinguisticVar, FuzzyRule, InferenceMethod, FIS
    └── Hazy.Inference.Evaluate -- evaluate (dispatches to Mamdani/Sugeno)
```

`Hazy.Inference.Mamdani` and `Hazy.Inference.Sugeno` are internal (`other-modules`). They are not importable by library consumers — all inference goes through `evaluate`.

### Key Design Principles

- **Purity first**: `evaluate :: FIS -> Map Text Double -> Map Text Double` — no IO, no state.
- **Membership functions are just functions**: `type MembershipFn = Double -> Degree`. No wrapper types.
- **T-norms/S-norms use typeclasses**: Extensible aggregation via `TNorm`/`SNorm` (MinMax, Product, Lukasiewicz).
- **Extensible defuzzification**: `Custom ([(FuzzySet, Degree)] -> Double)` for user-defined methods.

## Compiler & Language Settings

- GHC2024 language standard
- `-Wall -O2` enabled globally (see `common warnings` stanza in `hazy.cabal`)
- Base constrained to `^>=4.21.0.0`
- Cabal version 3.14

## Code Style

- All modules have explicit export lists.
- No comments on self-describing code. Comments only where they document non-obvious behavior (e.g., which t-norm is used, what a design choice means).
- Avoid unnecessary parens and redundant type annotations.

## Testing Approach

- Property-based tests (QuickCheck) for fuzzy logic axioms: t-norm commutativity/associativity/monotonicity/identity, membership function bounds [0,1], defuzzification within universe bounds
- Known-answer tests for membership function evaluation (e.g., `triangular 0 5 10` at x=5 returns 1.0)
- Integration tests for full inference pipeline via `evaluate`
- Tests import only public API — never internal modules like Mamdani/Sugeno directly
