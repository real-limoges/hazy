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

## Architecture

The library is organized in two layers:

- **Core** (`Hazy.Core.*`) — Domain-agnostic fuzzy logic: membership functions, t-norms/s-norms, operators, defuzzification.
- **Inference** (`Hazy.Inference.*`) — Mamdani and Sugeno inference engines. Defines linguistic variables, fuzzy rules, and the top-level `evaluate` function.

See [`docs/architecture.md`](docs/architecture.md) for the full design document.

## References

- Zadeh, L.A. (1965). *Fuzzy Sets*. Information and Control, 8(3), 338-353.
- Ross, T.J. *Fuzzy Logic with Engineering Applications*.
- Klir, G.J. & Yuan, B. *Fuzzy Sets and Fuzzy Logic: Theory and Applications*.

## License

BSD-3-Clause
