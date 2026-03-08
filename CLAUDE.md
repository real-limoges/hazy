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

### Module Hierarchy (planned)

- **`Hazy.Core.*`** — Domain-agnostic fuzzy logic primitives (types, membership functions, operators, t-norms, defuzzification)
- **`Hazy.Inference.*`** — Inference engines (Mamdani, Sugeno) and the top-level `evaluate` function

### Key Design Principles

- **Purity first**: The core `evaluate :: FIS -> Map Text Double -> Map Text Double` is pure — no IO, no state. Given the same FIS and inputs, always the same outputs.
- **Membership functions are just functions**: `type MembershipFn = Double -> Degree`. No wrapper, represented directly as what they are.
- **T-norms/S-norms use typeclasses**: Extensible aggregation operators via typeclasses (MinMax, Product, Lukasiewicz).

## Compiler & Language Settings

- GHC2024 language standard
- `-Wall -O2` enabled globally (see `common warnings` stanza in `hazy.cabal`)
- Base constrained to `^>=4.21.0.0`
- Cabal version 3.14

## Testing Approach

- Property-based tests (QuickCheck) for fuzzy logic axioms: t-norm commutativity/associativity/monotonicity/identity, membership function bounds [0,1], defuzzification within universe bounds
- Known-answer tests for membership function evaluation (e.g., `triangular 0 5 10` at x=5 returns 1.0)
- Integration tests for full inference pipeline
