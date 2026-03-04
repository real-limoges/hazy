# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Liminal is a general-purpose fuzzy logic library in Haskell with a mood state assessment application built on top. The library provides membership functions, fuzzy operators, t-norms/s-norms, Mamdani and Sugeno inference, and defuzzification. The mood application maps daily self-report inputs onto the circumplex model of affect as a (valence, activation) point.

## Build & Development Commands

```bash
cabal build              # Build the project
cabal test               # Run the test suite
cabal run liminal        # Run the executable
cabal clean              # Clean build artifacts
```

## Architecture

The codebase follows a layered architecture with strict separation between the domain-agnostic fuzzy logic library and the mood-specific application layer. Full architecture details are in `docs/architecture.md`.

### Module Hierarchy (planned)

- **`Liminal.Core.*`** — Domain-agnostic fuzzy logic primitives (types, membership functions, operators, t-norms, defuzzification)
- **`Liminal.Inference.*`** — Inference engines (Mamdani, Sugeno) and the top-level `evaluate` function
- **`Liminal.Mood.*`** — Mood-specific application layer (linguistic variables, circumplex rules, gap-as-signal logic)
- **`app/`** — Servant HTTP API wrapper (thin; the library does all the work)

### Key Design Principles

- **Purity first**: The core `evaluate :: FIS -> Map Text Double -> Map Text Double` is pure — no IO, no state. Given the same FIS and inputs, always the same outputs.
- **Library doesn't know about mood**: `Liminal.Core` and `Liminal.Inference` are domain-agnostic. `Liminal.Mood` is an application layer that could be swapped for any other fuzzy logic application.
- **Membership functions are just functions**: `type MembershipFn = Double -> Degree`. No wrapper, represented directly as what they are.
- **T-norms/S-norms use typeclasses**: Extensible aggregation operators via typeclasses (MinMax, Product, Lukasiewicz).
- **Gaps are data, not missing data**: Absence of a mood log entry is itself a fuzzy input (`daysSinceLastEntry`), not something to impute.

## Compiler & Language Settings

- GHC2024 language standard
- `-Wall -O2` enabled globally (see `common warnings` stanza in `liminal.cabal`)
- Base constrained to `^>=4.21.0.0`
- Cabal version 3.14

## Testing Approach

- Property-based tests (QuickCheck) for fuzzy logic axioms: t-norm commutativity/associativity/monotonicity/identity, membership function bounds [0,1], defuzzification within universe bounds
- Known-answer tests for membership function evaluation (e.g., `triangular 0 5 10` at x=5 returns 1.0)
- Integration tests for full inference pipeline

## External Integration

Liminal is designed to run as a standalone Servant HTTP microservice (`/infer`, `/health`, `/rules` endpoints) consumed by a separate Phoenix/Elixir application called Fugue via JSON over HTTP.