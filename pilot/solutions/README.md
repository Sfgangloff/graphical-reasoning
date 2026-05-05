# `pilot/solutions/`

Pilot solutions to selected Putnam problems formalized in
`putnam/real_analysis/`. Each problem produces two files:

| File | Purpose |
| --- | --- |
| `<id>_solution.lean` | Lean 4 (Mathlib) solution / proof skeleton. |
| `<id>_log.md`        | Chronological log of every tool call used while producing the solution: which tool, why, what came out of it. |

The original problem files in `putnam/real_analysis/` are **never
modified**; everything new lives here.

## Working constraints

For these pilot solutions only two tool families are used:

- **`lean-lsp`** — proof-state inspection, Mathlib search
  (`lean_leansearch`, `lean_loogle`, `lean_local_search`),
  and diagnostics (`lean_diagnostic_messages`).
- **`math-viz`** — quick plotting (`plot_function`) for sanity-checking
  the direction of an inequality before formalization.

Plus the unavoidable `Read` / `Write` / `Bash` for file I/O.

No web search, no agent delegation, no `math-compute` (SymPy/Z3),
no `lean_multi_attempt` / `lean_state_search` / `lean_hammer_premise`,
no `lean_run_code` / `lean_build`.

## Conventions

* Each `*_solution.lean` opens with a docstring explaining (1) the
  problem, (2) any caveats about the original Lean statement,
  (3) the proof strategy, and (4) what is fully proved vs. left as
  `sorry`.
* Lemmas left as `sorry` always carry a paper-style proof sketch in
  their docstring.
* The final theorem is always **fully reduced** to those named lemmas
  — no `sorry` is hidden inside a tactic block.
* Compilation: `lean_diagnostic_messages` should report **zero
  errors**; the only warnings should be the intentional `sorry`s.

## Catalog

### Putnam 2025

#### `A2_solution.lean` — find largest `a`, smallest `b` with `ax(π−x) ≤ sin x ≤ bx(π−x)` on `[0, π]`.

* **Status of the original Lean statement.** *Mathematically false.*
  The year file claims `a = 4/π²` and `b = 1`. Visualization showed
  `4/π² · x · (π−x)` lies *above* `sin x` (so it cannot be a lower
  bound); the actual answers are `a = 1/π`, `b = 4/π²`.
* **Fully proved.** A disproof of the original via the rational
  counterexample `x = π/6` (`5/9 > 1/2`); both *easy* directions of the
  corrected `IsGreatest`/`IsLeast` (the strict-monotone "no greater
  `a` works" argument and the `x = π/2` lower bound on `b`).
* **`sorry` (with proof sketches).** The two analytic inequalities
  `(1/π)·x·(π−x) ≤ sin x` and `sin x ≤ (4/π²)·x·(π−x)` on `[0, π]`.

#### `B2_solution.lean` — centroid shifts right under `f → f²`.

* **Status of the original.** Correct as stated.
* **Fully proved.** The strict-positivity helper `f_pos_of_mem_Ioc`,
  and the final theorem reduces (via `div_lt_div_iff₀`) cleanly to the
  three named lemmas below.
* **`sorry` (with proof sketches).** Positivity of `∫₀¹ f` and
  `∫₀¹ f²`; the Chebyshev/correlation cross-multiplied inequality
  (Fubini + symmetrization).

## Reading the logs

The `*_log.md` files are deliberately verbose. Each tool call answers
three questions:

1. **Why this tool?** — what alternative was considered.
2. **What came back?** — concrete output (lemma name, plot conclusion,
   error message).
3. **Was it useful?** — sometimes the most informative calls are the
   ones that *fail* (rate limits) or that *negatively* confirm a
   hypothesis (e.g. "no off-the-shelf integral Chebyshev in Mathlib").

The intent is that the logs be useful to someone retracing the
reasoning, not just a diary.
