# Putnam formalization task — Condition OPTIONAL_PATH_ONLY (lean-lsp + math-viz-path-only, viz optional, path-only return)

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
2. States the problem as a Lean theorem named `putnam_<id>`, where
   `<id>` is the problem id lowercased with the dot replaced by an
   underscore (e.g., `1985.B5` → `putnam_1985_b5`). The statement must
   faithfully capture every hypothesis and conclusion of the LaTeX
   problem — no stronger, no weaker.
3. **If the problem asks "Evaluate / Find / Compute / Determine"** (an
   answer must be supplied), define the answer as a typed Lean term:

   ```
   noncomputable def putnam_<id>_solution : <type> := <closed form>
   ```

   and use that name on the right-hand side of the theorem:

   ```
   theorem putnam_<id> : <LHS> = putnam_<id>_solution := by …
   ```

   The answer **must** be a Lean term that compiles. Stating the answer
   in a comment, docstring, or in the JSON `notes` field does NOT
   count — it will be scored as "no answer provided" even if the prose
   is correct. The answer term is judged independently of the proof,
   so this is the part you should never skip.
4. Contains a **complete proof**. No `sorry`, no `admit`, no
   axiom-style escapes. The file must build cleanly with `lake build`.

Partial submissions: if the budget runs out before you finish the
proof, the `putnam_<id>_solution` def with the correct closed form
must still be present and well-typed. A `theorem … := by sorry` is an
acceptable fallback **for the proof**, but the answer term is not
optional.

## Tools you may use

- **`lean-lsp-mcp`** in full (`lean_goal`, `lean_diagnostic_messages`,
  `lean_hover_info`, `lean_local_search`, `lean_leansearch`,
  `lean_loogle`, `lean_state_search`, `lean_hammer_premise`,
  `lean_multi_attempt`, `lean_completions`, `lean_declaration_file`,
  `lean_verify`).
- **`math-viz-path-only`** in full (`plot_function`, `plot_implicit`,
  `plot_region`, `plot_phase_portrait`, `plot_parametric`,
  `plot_surface`, `plot_partial_sums`, `plot_cobweb`,
  `plot_integrand_with_shading`, `draw_graph`, `draw_matrix`,
  `draw_poset`, `draw_simplicial_complex`, `render_latex`).
- `Read` and `Edit` / `Write` on files **in this working directory only**
  (and viewing PNGs that `math-viz-path-only` writes to its image directory).
- `Bash` only for `lake build` (and trivial filesystem operations like
  `ls`, `cat`).

You may **not** use other tools.

## Budget

Stop work and emit the final JSON below by **{{WRAPUP_MINUTES}} minutes
wall-clock** OR **{{BUDGET_TOOL_CALLS}} tool calls**, whichever comes
first. The harness will hard-stop at {{BUDGET_MINUTES}} minutes, so if
you blow past {{WRAPUP_MINUTES}} the self-report will be lost. If
unsolved when the budget is hit, save partial progress and report.

## Final output

When finished (whether solved, partial, or out-of-budget), output
exactly one JSON block as your last message, in this schema:

```json
{
  "problem_id": "{{PROBLEM_ID}}",
  "condition": "optional_path_only",
  "outcome": "solved" | "partial" | "failed" | "timeout",
  "sorries_remaining": <int>,
  "tool_calls_total": <int>,
  "tool_calls_viz": <int>,
  "decisive_tool": "<tool name or null>",
  "notes": "<one sentence: what worked, or where you got stuck>"
}
```
