# graphical-reasoning

**An experiment: do graphical-representation tools (plotting, diagram
rendering, geometric visualization) actually help Claude Code solve
math problems where visualization is known to help humans?**

The hypothesis is simple: if a competent human's first move on a
problem is to *draw something* — sketch a curve, mark equality cases,
plot a ratio, draw a phase portrait — then giving an LLM agent the
same affordance (via MCP plotting tools, etc.) should change what it
can solve and how it gets there. This repository is the test harness
for that hypothesis.

## What's here

* A **statement-level Lean 4 / Mathlib formalization** of the
  real-analysis problems from the **Putnam Competition, 1985–2025**.
  The Putnam corpus is the *substrate* of the experiment: it's a
  large, well-curated set of problems, many of which classically yield
  to a picture (find the largest constant such that one curve sits
  below another; identify the centroid of a region; analyze a phase
  portrait; etc.).
* A **`pilot/solutions/` track** where individual problems are
  attempted under a deliberately restricted tool budget so that the
  effect of graphical tools is *measurable* rather than confounded.

## The experimental setup

For each pilot solution, the agent (Claude Code) is restricted to:

* **`lean-lsp`** — proof-state inspection, Mathlib search, diagnostics.
* **`math-viz`** — quick plotting (`plot_function` and friends).
* `Read` / `Write` / `Bash` for file I/O only.

No web search, no agent delegation, no symbolic-math servers
(`math-compute`/SymPy/Z3), no tactic-enumeration helpers
(`lean_multi_attempt`, `lean_state_search`, `lean_hammer_premise`),
no `lean_run_code` / `lean_build`.

The discipline isolates the *visualization* tool. If the agent solves
a problem (or, just as informatively, *catches an error in the
problem statement*) thanks to a plot, the log will show it.

## Reading the experiment

Each pilot ships two artifacts:

| File                  | Purpose |
| --------------------- | --- |
| `<id>_solution.lean`  | The actual Lean solution / proof skeleton. |
| `<id>_log.md`         | A **chronological log of every tool call**: which tool, why it was chosen, what came back, whether it was useful. |

The logs are the primary scientific output — they let a reader judge
*which calls actually moved the needle*. Conventions:

* No `sorry` is hidden inside a tactic block. Every `sorry` is at a
  named lemma with a paper-style docstring sketch.
* `lean_diagnostic_messages` is expected to report **zero errors**;
  the only warnings should be the intentional `sorry`s.
* Each tool call in the log answers: *why this tool*, *what came
  back*, *was it useful (including useful-by-failing)*.

See `pilot/solutions/README.md` for the long-form conventions.

## Findings so far

* **Putnam 2025 A-2** (`pilot/solutions/A2_solution.lean`).
  *Visualization-decisive.* The original Lean statement claims
  `a = 4/π²` is the largest constant with `a·x·(π−x) ≤ sin x` on
  `[0, π]`. A single `math-viz` plot of `sin x`, `(4/π²)·x·(π−x)`, and
  `(1/π)·x·(π−x)` immediately shows the parabola sits *above* `sin`,
  invalidating the claim. The pilot then formalizes a counterexample
  at `x = π/6` (`5/9 > 1/2`), states the corrected theorem
  (`a = 1/π`, `b = 4/π²`), and proves both easy directions. Without
  the plot the agent would have spent its budget trying to prove a
  false theorem.
* **Putnam 2025 B-2** (`pilot/solutions/B2_solution.lean`).
  *Visualization-confirmatory.* A centroid inequality of Chebyshev
  type. Plotting `f(x) = x` against `f(x)² = x²` confirms the
  direction of the inequality (the `f²`-density skews the centroid
  right) and supplies a numerical sanity check (`2/3 < 3/4`). The
  pilot reduces the theorem to three named technical lemmas.

The two cases illustrate two distinct uses of the visualization tool:
*detecting a false claim* and *confirming the qualitative direction
before formalization*.

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
│                                       with one .lean file per
│                                       formalized real-analysis
│                                       problem (e.g. `A2.lean`).
└── pilot/
    └── solutions/                    — pilot solutions to selected problems
        ├── README.md                 — conventions for the pilot track
        ├── A2_solution.lean / A2_log.md   (Putnam 2025 A-2)
        └── B2_solution.lean / B2_log.md   (Putnam 2025 B-2)
```

`Putnam.lean` is a thin index that `import`s every formalized problem,
so a single `lake build` checks the whole repository.

## Building

Requires the [Lean toolchain](https://leanprover-community.github.io/get_started.html)
matching `lean-toolchain`, plus `elan` / `lake`.

```bash
lake exe cache get      # fetch precompiled Mathlib oleans (recommended; otherwise the first build can take hours)
lake build              # type-checks every formalized problem
```

## Status

* **Statements** for 1985–2025 real-analysis problems: present.
* **Proofs** in `putnam/`: mostly `sorry`.
* **Pilot solutions** in `pilot/solutions/`: two prototypes
  (Putnam 2025 A-2 and B-2). More to come; each one becomes one data
  point in the experiment.

## Contributing

The repo is most useful if the pilot track keeps expanding. PRs
welcome, especially:

* **New pilot solutions** for problems where graphical reasoning seems
  likely to matter — anything where you would *naturally draw the
  picture* before computing. Please follow the log-everything
  conventions in `pilot/solutions/README.md`.
* **Negative data points** — pilots where graphical tools turned out
  *not* to help. These are scientifically important; they bound the
  hypothesis.
* **Statement-level fixes** for any mis-stated problems, as happened
  with Putnam 2025 A-2.
* **Expanding the proof corpus** in `putnam/` (no tool restriction;
  this is the substrate, not the experiment).
