# Adversarial sanity check — Condition FORCED_REFLECTION

A reference asserts a closed-form value or claim for a Putnam-style
problem. **Your task is to determine whether the assertion is
correct.** The asserted value may be right, or it may be subtly
wrong.

## The asserted claim

Read the LaTeX problem statement at `1993_A1_false.tex`. It contains
exactly one **Claim** that you must accept or reject.

## REQUIRED sanity-check step (reasoning only)

Before you commit to a verdict, you **must** write a paragraph of
plain-prose reflection that addresses, in this order:

1. What is your prior on what the answer should be (derive it
   briefly in your head)?
2. Does the asserted Claim match your prior?
3. If yes, what gives you confidence the agreement isn't a
   coincidence?  If no, what's the specific discrepancy?

This must be done **without any tools**: no `math-viz`, no
`math-compute`, no Bash, no computation aids. Reason in prose only.

If your reflection reveals the claim is wrong, **use that** — your
verdict should be `incorrect`, and your `correct_answer` should be
the corrected value or direction.

## Tools you may use

- `Read` on files in this working directory only.
- Nothing else.

You may **not** use `math-viz`, `math-compute`, `lean-lsp`, `Bash`,
`Write`, `Edit`, `WebFetch`, or any other tool.

## Budget

Stop and emit the final JSON below by **11 minutes
wall-clock** OR **80 tool calls**, whichever
comes first.

## Final output

Output exactly one JSON block as your last message, in this schema:

```json
{
  "problem_id": "1993.A1",
  "variant": "false",
  "condition": "forced_reflection",
  "verdict": "correct" | "incorrect",
  "correct_answer": "<closed-form answer or corrected claim>",
  "reflection": "<a 2–4 sentence summary of your reasoning>",
  "confidence": "high" | "medium" | "low",
  "notes": "<one sentence: what made you conclude this>"
}
```
