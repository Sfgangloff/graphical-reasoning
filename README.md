# graphical-reasoning

A Lean 4 (Mathlib) formalization of the **real-analysis problems from
the Putnam Competition, 1985 – 2025**, together with a small
`pilot/solutions/` track that experiments with solving selected
problems under a deliberately restricted tool budget.

## Layout

```
.
├── Putnam.lean                       — index module (imports every formalized problem)
├── lakefile.toml                     — Lake build config; depends on Mathlib (master)
├── lean-toolchain                    — pinned Lean toolchain
├── putnam/
│   ├── raw/                          — raw .tex problem sets, 1985.tex … 2025.tex
│   └── real_analysis/
│       ├── real_analysis_problems.tex
│       └── Y1985/, Y1986/, …, Y2025/ — one folder per Putnam year,
│                                       containing one .lean file per
│                                       formalized real-analysis
│                                       problem (e.g. `A2.lean`, `B3.lean`).
└── pilot/
    └── solutions/                    — pilot solutions to selected problems
        ├── README.md
        ├── A2_solution.lean / A2_log.md   (Putnam 2025 A-2)
        └── B2_solution.lean / B2_log.md   (Putnam 2025 B-2)
```

`Putnam.lean` is a thin index that `import`s every formalized problem,
so a single `lake build` checks the whole repository.

## Scope

* **41 years**: 1985 through 2025.
* Only the **real-analysis** problems from each contest are
  formalized — algebra, combinatorics, number theory, geometry are
  out of scope here.
* Each formalization in `putnam/real_analysis/Y####/` states the
  problem as a Lean theorem and (for the most part) leaves the proof
  as `sorry`. The repo is currently a **statement-level**
  formalization; full proofs are an open task and are being prototyped
  in `pilot/solutions/`.

## Building

Requires the [Lean toolchain](https://leanprover-community.github.io/get_started.html)
matching `lean-toolchain` and `elan`/`lake`.

```bash
lake exe cache get      # fetch precompiled Mathlib oleans (recommended; otherwise the first build can take hours)
lake build              # type-checks every formalized problem
```

## The pilot track (`pilot/solutions/`)

A separate experiment in **constrained problem-solving with an LLM**.
Each pilot solution is produced under a tight tool budget — only
`lean-lsp` (proof-state inspection, Mathlib search, diagnostics) and
`math-viz` (plotting) — and ships with two artifacts:

| File                  | Purpose |
| --------------------- | --- |
| `<id>_solution.lean`  | The actual Lean solution / proof skeleton. |
| `<id>_log.md`         | Chronological tool-usage log: which tool was called, why it was chosen, and what came back. |

See `pilot/solutions/README.md` for full conventions. Notable findings
so far:

* **Putnam 2025 A-2** — the *original Lean statement is mathematically
  false* (it asserts `a = 4/π²` is the largest constant in
  `a · x · (π−x) ≤ sin x`, but `4/π²` violates this at `x = π/6`). The
  pilot solution disproves the original, restates the problem with the
  correct constants `a = 1/π`, `b = 4/π²`, and proves the easy
  directions cleanly.
* **Putnam 2025 B-2** — a centroid inequality of Chebyshev type. The
  pilot solution reduces it via `div_lt_div_iff₀` to three named
  lemmas (two positivity statements and the symmetrized cross
  inequality); the final theorem is fully reduced, the underlying
  technical pieces are `sorry` with paper-style proof sketches.

## Status

* **Statements** for 1985 – 2025 real-analysis problems: present.
* **Proofs**: mostly `sorry`. Pilot solutions for two 2025 problems
  exist as prototypes.
* The pilot README discusses what counts as a "complete" solution in
  this repo (no hidden `sorry`s in tactic blocks; every `sorry` is at
  a named lemma with a docstring sketch).

## Contributing

PRs welcome, especially:

* completing proofs for problems whose statements are present,
* adding solutions to the `pilot/` track (please follow the
  log-everything conventions documented in `pilot/solutions/README.md`),
* flagging or correcting any **mis-stated** problems, as happened with
  Putnam 2025 A-2.
