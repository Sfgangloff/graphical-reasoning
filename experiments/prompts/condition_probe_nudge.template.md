# Putnam formalization task — probe / prose+nudge framing

You are formalizing and proving Putnam problem **{{PROBLEM_ID}}** in
Lean 4 with Mathlib.

## The problem

Read the LaTeX statement of the problem from the file:

```
{{EXCERPT_PATH}}
```

(It contains exactly one Putnam problem in natural-language LaTeX.)

**Use the available tools as appropriate** — visualization
(`math-viz`), symbolic computation (`math-compute`), and Lean
introspection (`lean-lsp-mcp`) are all available and you should reach
for them whenever they would help you understand the problem, test a
conjectured closed form, or check intermediate algebra. Do not feel
obliged to solve the problem by reasoning alone.

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

   and use that name on the right-hand side of the theorem. The answer
   term must compile.
4. Contains a **complete proof**. No `sorry`, no `admit`. The file
   must build cleanly with `lake build`.

A `theorem … := by sorry` is an acceptable fallback for the proof if
the budget runs out, but the answer term is not optional.

## Tools you may use

- **`lean-lsp-mcp`** in full.
- **`math-viz`** in full.
- **`math-compute`** in full (sympy_eval, sympy_solve, sympy_diff,
  sympy_integrate, sympy_factor, sympy_expand, batch_examples,
  conjecture_test, find_counterexample, z3_check, oeis_lookup).
- `Read`, `Edit`, `Write` on files **in this working directory only**.
- `Bash` only for `lake build` (and trivial `ls`, `cat`).

You may **not** use other tools.

## Budget

Stop work and emit the final JSON below by **{{WRAPUP_MINUTES}} minutes
wall-clock** OR **{{BUDGET_TOOL_CALLS}} tool calls**, whichever comes
first. The harness hard-stops at {{BUDGET_MINUTES}} minutes.

## Final output

When finished, output exactly one JSON block as your last message:

```json
{
  "problem_id": "{{PROBLEM_ID}}",
  "framing": "prose+nudge",
  "outcome": "solved" | "partial" | "failed" | "timeout",
  "sorries_remaining": <int>,
  "tool_calls_total": <int>,
  "notes": "<one sentence>"
}
```
