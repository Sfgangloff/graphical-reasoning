# Adversarial sanity check — Condition FORCED_TEXTUAL

A reference asserts a closed-form value or claim for a Putnam-style
problem. **Your task is to determine whether the assertion is
correct.** The asserted value may be right, or it may be subtly
wrong.

## The asserted claim

Read the LaTeX problem statement at `1991_A5_true.tex`. It contains
exactly one **Claim** that you must accept or reject.

## REQUIRED sanity-check step (numerical)

Before you commit to a verdict, you **must** evaluate the central
quantity at **at least three concrete test inputs** and compare to
the asserted value. Use `math-compute` tools (`sympy_eval`,
`sympy_integrate`, `batch_examples`, `conjecture_test`) for this.

1. For a closed-form integral or sum: compute its numerical value at
   2–3 specific parameter values, and compare to what the asserted
   formula gives at those same values.
2. For an inequality: evaluate both sides at 2–3 concrete values of
   the parameter, and check whether the asserted direction holds.
3. Write one sentence stating what the numbers tell you — does the
   asserted value match the computed numerics? does the inequality
   hold in the asserted direction?

**No plotting and no images.** You are doing this entirely with
numbers.

If the numerics reveal the claim is wrong, **use that** — your
verdict should be `incorrect`, and your `correct_answer` should be
the corrected value or direction.

## Tools you may use

- **`math-compute`** in full (`sympy_eval`, `sympy_integrate`,
  `sympy_solve`, `sympy_diff`, `sympy_factor`, `sympy_expand`,
  `batch_examples`, `conjecture_test`, `find_counterexample`,
  `z3_check`, `oeis_lookup`).
- `Read` on files in this working directory.
- `Bash` only for simple `ls` / `cat`.

You may **not** use `math-viz`, `lean-lsp`, `Write`, `Edit`,
`WebFetch`, or any other tool.

## Budget

Stop and emit the final JSON below by **11 minutes
wall-clock** OR **80 tool calls**, whichever
comes first.

## Final output

Output exactly one JSON block as your last message, in this schema:

```json
{
  "problem_id": "1991.A5",
  "variant": "true",
  "condition": "forced_textual",
  "verdict": "correct" | "incorrect",
  "correct_answer": "<closed-form answer or corrected claim>",
  "numeric_verdict": "<one-sentence verdict from the required step, including the numbers you computed>",
  "confidence": "high" | "medium" | "low",
  "notes": "<one sentence: what made you conclude this>"
}
```
