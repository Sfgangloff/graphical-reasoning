# Putnam formalization task — Condition B (lean-lsp + math-viz)

You are formalizing and proving Putnam problem **{{PROBLEM_ID}}** in
Lean 4 with Mathlib.

## The problem

Read the LaTeX statement of the problem from the file:

```
{{EXCERPT_PATH}}
```

(It contains exactly one Putnam problem in natural-language LaTeX.)

## What to deliver

Write a complete Lean 4 file at `Solution.lean` that:

1. Imports `Mathlib`.
2. States the problem as a Lean theorem (or definition + theorem if the
   problem asks for an explicit value/closed form). The statement must
   faithfully capture every hypothesis and conclusion of the LaTeX
   problem — no stronger, no weaker.
3. Contains a **complete proof**. No `sorry`, no `admit`, no
   axiom-style escapes. The file must build cleanly with `lake build`.

If the problem asks "Evaluate / Find / Compute X", state the answer as
the right-hand side of the theorem, or as an explicit `def`, and prove
it.

## Tools you may use

- **`lean-lsp-mcp`** in full (`lean_goal`, `lean_diagnostic_messages`,
  `lean_hover_info`, `lean_local_search`, `lean_leansearch`,
  `lean_loogle`, `lean_state_search`, `lean_hammer_premise`,
  `lean_multi_attempt`, `lean_completions`, `lean_declaration_file`,
  `lean_verify`).
- **`math-viz`** in full (`plot_function`, `plot_implicit`,
  `plot_region`, `plot_phase_portrait`, `plot_parametric`,
  `plot_surface`, `plot_partial_sums`, `plot_cobweb`,
  `plot_integrand_with_shading`, `draw_graph`, `draw_matrix`,
  `draw_poset`, `draw_simplicial_complex`, `render_latex`).
- `Read` and `Edit` / `Write` on files **in this working directory only**
  (and viewing PNGs that `math-viz` writes to its image directory).
- `Bash` only for `lake build` (and trivial filesystem operations like
  `ls`, `cat`).

There is **no requirement to use the visualization tools** — use them
only if you find them genuinely useful.

You may **not** use:

- Any symbolic-math tools (`sympy_*`, `z3_*`, `conjecture_test`,
  `find_counterexample`, OEIS lookup, etc.).
- Any web search, external lookup, or agent delegation.
- Files outside this working directory. Specifically: do **not** read
  files in any `putnam/` directory, even if you find one. The reference
  formalization is *not* available in this experiment.

## Budget

Stop after **{{BUDGET_MINUTES}} minutes wall-clock OR
{{BUDGET_TOOL_CALLS}} tool calls**, whichever comes first. If unsolved
when the budget is hit, save partial progress and report.

## Final output

When finished (whether solved, partial, or out-of-budget), output
exactly one JSON block as your last message, in this schema:

```json
{
  "problem_id": "{{PROBLEM_ID}}",
  "condition": "B",
  "outcome": "solved" | "partial" | "failed" | "timeout",
  "sorries_remaining": <int>,
  "tool_calls_total": <int>,
  "tool_calls_viz": <int>,
  "decisive_tool": "<tool name or null>",
  "notes": "<one sentence: what worked, or where you got stuck>"
}
```
