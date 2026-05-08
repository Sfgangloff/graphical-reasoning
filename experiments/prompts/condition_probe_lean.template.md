# Putnam formalization task — probe / lean-statement framing

You are proving Putnam problem **{{PROBLEM_ID}}** in Lean 4 with
Mathlib.

## The problem

The Lean 4 theorem statement to prove is in the file:

```
Theorem.lean
```

Open it. It contains the `import`, the namespace, an answer stub
(`solution : <type> := sorry`) where the problem requires a closed
form, and the `theorem` whose proof is `sorry`. Your job is to:

1. Replace any `:= sorry` in the answer stub with the correct typed
   closed form (so that the answer term compiles).
2. Replace the `sorry` in the proof with a complete proof.

Save the result as `Solution.lean` (copy the file's contents over and
edit). The harness will run `lake build` on `Solution.lean`.

## What to deliver

`Solution.lean` must:

1. Compile cleanly with `lake build`.
2. Contain the same theorem signature as `Theorem.lean` (do not
   weaken hypotheses, change the conclusion, or rename the theorem).
3. Have no `sorry` or `admit` in either the answer term or the proof.

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
  "framing": "lean-stmt",
  "outcome": "solved" | "partial" | "failed" | "timeout",
  "sorries_remaining": <int>,
  "tool_calls_total": <int>,
  "notes": "<one sentence>"
}
```
