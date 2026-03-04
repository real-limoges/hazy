# Liminal

A general-purpose fuzzy logic library in Haskell, with a mood state assessment application built on top.

The name comes from the Latin *limen* (threshold) — the space that's neither fully one thing nor another. That's what fuzzy membership captures: the threshold between "tall" and "not tall", between "rested" and "exhausted".

## What This Is

1. A **fuzzy logic library** — membership functions, fuzzy operators, t-norms/s-norms, Mamdani and Sugeno inference, defuzzification.
2. A **mood state assessment application** — takes daily self-report inputs (sleep, energy, irritability, etc.), runs fuzzy inference, and maps the result onto the [circumplex model of affect](https://en.wikipedia.org/wiki/Emotion_classification#Circumplex_model) as a (valence, activation) point.

```
            High Activation
                 (+1)
                  |
    Distressed    |    Excited
    Anxious       |    Elated
    Tense         |    Happy
                  |
 (-1) -----------+----------- (+1)
 Negative         |          Positive
  Valence         |          Valence
                  |
    Sad           |    Calm
    Depressed     |    Relaxed
    Bored         |    Serene
                  |
                (-1)
            Low Activation
```

## Building

Requires GHC 9.12+ and Cabal 3.14+.

```bash
cabal build
cabal test
cabal run liminal
```

## Architecture

The library is organized in three layers:

- **Core** (`Liminal.Core.*`) — Domain-agnostic fuzzy logic: membership functions, t-norms/s-norms, operators, defuzzification.
- **Inference** (`Liminal.Inference.*`) — Mamdani and Sugeno inference engines. Defines linguistic variables, fuzzy rules, and the top-level `evaluate` function.
- **Mood** (`Liminal.Mood.*`) — Application layer mapping 7 self-report inputs (sleep, energy, mood elevation, anhedonia, racing thoughts, irritability, psychomotor activity) to circumplex coordinates. Treats logging gaps as a signal, not missing data.

The core library knows nothing about mood — it's reusable for any fuzzy logic application.

See [`docs/architecture.md`](docs/architecture.md) for the full design document.

## API

Liminal exposes a Servant HTTP API for integration with [Fugue](https://github.com/reallimoges/fugue), a Phoenix LiveView frontend.

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/infer` | POST | Submit mood inputs, receive (valence, activation, confidence) |
| `/health` | GET | Health check |
| `/rules` | GET | Introspect the active rule base |

## References

- Zadeh, L.A. (1965). *Fuzzy Sets*. Information and Control, 8(3), 338-353.
- Ross, T.J. *Fuzzy Logic with Engineering Applications*.
- Klir, G.J. & Yuan, B. *Fuzzy Sets and Fuzzy Logic: Theory and Applications*.
- Russell, J.A. (1980). *A circumplex model of affect*. Journal of Personality and Social Psychology.

## License

BSD-3-Clause