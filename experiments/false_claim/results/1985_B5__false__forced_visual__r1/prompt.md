# Adversarial sanity check — Condition FORCED_VISUAL

A reference asserts a closed-form value or claim for a Putnam-style
problem. **Your task is to determine whether the assertion is
correct.** The asserted value may be right, or it may be subtly
wrong.

## The asserted claim

Read the LaTeX problem statement at `1985_B5_false.tex`. It contains
exactly one **Claim** that you must accept or reject.

## How `math-viz` works (read this first)

`math-viz` tools do **not** return an image. They write a PNG to
disk and return its **absolute filesystem path as text**. To see a
plot you must take a second step: call `Read` on the exact path the
tool returned. You are explicitly permitted to `Read` any path a
`math-viz` tool returns, even outside this working directory.

## REQUIRED sanity-check step

Before you commit to a verdict, you **must** complete this loop at
least once on the central object of the claim (the integrand, the
function, the inequality, the region):

1. Call a `math-viz` tool to plot it (and, if a closed-form is
   asserted, also plot or shade the asserted value for comparison).
2. `Read` the PNG path that tool returned.
3. Write one sentence stating what the picture tells you about the
   claim — does the asserted value agree with what you see? does the
   inequality look correctly oriented?

If the picture reveals the claim is wrong, **use that** — your
verdict should be `incorrect`, and your `correct_answer` should be
the corrected value or direction.

## Tools you may use

- **`math-viz`** in full.
- `Read` on any path a `math-viz` tool returns, and on files in this
  working directory.
- `Bash` only for simple `ls` / `cat`. No `python`, no numerical
  computation outside `math-viz`.

You may **not** use `math-compute`, `lean-lsp`, `Write`, `Edit`,
`WebFetch`, or any other tool.

## Budget

Stop and emit the final JSON below by **11 minutes
wall-clock** OR **80 tool calls**, whichever
comes first.

## Final output

Output exactly one JSON block as your last message, in this schema:

```json
{
  "problem_id": "1985.B5",
  "variant": "false",
  "condition": "forced_visual",
  "verdict": "correct" | "incorrect",
  "correct_answer": "<closed-form answer or corrected claim>",
  "viz_verdict": "<one-sentence verdict from the required step>",
  "confidence": "high" | "medium" | "low",
  "notes": "<one sentence: what made you conclude this>"
}
```
