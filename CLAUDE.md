# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Hazy is a fuzzy logic DSL in Racket, building toward `#lang hazy`. It models vagueness via membership functions (closures from reals to [0,1]), composed through t-norms, hedges, and Mamdani inference.

## Commands

```bash
raco pkg install --auto --no-docs   # install package (first time / CI)
raco test tests/                    # run all tests
raco test tests/main.rkt            # run a single test file
```

## Architecture

Hazy is layered — each layer depends only on those below it:

```
membership.rkt    → constructors (triangular, gaussian, etc.) returning closures
fuzzy-ops.rkt     → pointwise operations (fuzzy-and, fuzzy-or, fuzzy-not)
linguistic.rkt    → linguistic-var struct, hedge functions (very, somewhat, slightly)
rules.rkt         → fuzzy-rule/fuzzy-condition structs, antecedent evaluation
inference.rkt     → mamdani-infer: rules + bindings → aggregated membership function
defuzz.rkt        → centroid: aggregated membership function → crisp output
main.rkt          → public API re-export (uses racket/base)
lang/reader.rkt   → #lang hazy reader (planned)
lang/expander.rkt → #lang hazy expander with syntax-parse macros (planned)
```

The core pattern: every membership function constructor closes over shape parameters and returns a `(lambda (x) ...)`. All composition (AND, OR, hedges) produces new lambdas — no intermediate data structures.

## Key Files

- `info.rkt` — package metadata, collection name "hazy", deps
- `docs/IMPL.md` — implementation guide with 8 sequential stages and 9 recipe cards
- `docs/THEORY.md` — mathematical derivations behind every design decision
- `docs/ROADMAP.md` — non-linear roadmap with dependency tracking

## Conventions

- `#lang racket/base` with explicit requires (not `#lang racket`)
- `#:transparent` on all structs
- No mutation (`set!` is a code smell) — use `for/fold` over manual accumulation
- Contracts at `provide` boundaries only, not on internal helpers
- Tests use `module+ test` inline or `tests/` directory with rackunit
- Floating-point comparisons: use `check-=` with epsilon, not `check-equal?`
- Naming: `predicate?`, `mutator!`, `converter->target`
