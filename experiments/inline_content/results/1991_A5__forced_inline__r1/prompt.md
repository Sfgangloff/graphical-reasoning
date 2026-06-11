# Putnam formalization task — Condition FORCED_INLINE (lean-lsp + math-viz, viz required, upstream inline-image return)

You are formalizing and proving Putnam problem **1991.A5** in
Lean 4 with Mathlib.

## The problem

Read the LaTeX statement of the problem from the file:

```
1991_A5.tex
```

(It contains exactly one Putnam problem in natural-language LaTeX.)

## How `math-viz` works (read this before anything else)

`math-viz` tools do **not** return an image. They write a PNG to disk
and return its **absolute filesystem path as text**. To actually see a
plot you must take a second step: call `Read` on the exact path the
tool returned. That path may be outside this working directory — read
it anyway; you are explicitly permitted to `Read` any path a
`math-viz` tool returns. A plot you never `Read` tells you nothing.

The useful pattern is a three-step loop:

> **plot → `Read` the returned PNG path → state in one sentence what
> the picture tells you about the math.**

Worked example. For an integral-evaluation problem "Evaluate
∫ f(x) dx = ?", before committing to a closed form: `plot_function`
the integrand (and, if you have a conjectured value, also plot the
antiderivative or the running integral), `Read` the PNG, and check —
is the integrand the sign you assumed? does it blow up? does the
area look like your conjectured constant? For an inequality "show
g(x) ≤ h(x)", plot both sides, `Read` the PNG, and read off whether
one is everywhere above the other (and thus the *direction* of the
inequality you must prove). This routinely catches a wrong closed
form or a backwards inequality **before** you waste the budget
proving something false.

## REQUIRED diagnostic step

Before you write the final `Solution.lean`, you **must** complete the
plot → `Read` → verdict loop at least once on the central object of
this problem (the integrand, the function, the region, the sequence —
whatever the problem is about):

1. Call a `math-viz` tool on it.
2. `Read` the PNG path that tool returned.
3. Write one sentence — your *verdict* — stating what the picture
   tells you about the answer or the claim (e.g. "the integrand is
   positive and decays like e^{-t}, so the integral converges and
   looks ≈ 0.89", or "the stated identity is FALSE — the curves cross
   near x=1.3"). Put this sentence in the `viz_verdict` field of the
   final JSON.

If the picture reveals the obvious closed form or that the stated
claim is false, **use that** — let it steer the formalization. This
step is not optional and is not a formality; it is the point of this
condition.

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
optional, and the required diagnostic step above is not optional.

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
- `Read` on **any path a `math-viz` tool returns** (even outside this
  working directory), and `Read` / `Edit` / `Write` on files in this
  working directory.
- `Bash` only for `lake build` (and trivial filesystem operations like
  `ls`, `cat`).

You may **not** use other tools.

## Budget

Stop work and emit the final JSON below by **11 minutes
wall-clock** OR **80 tool calls**, whichever comes
first. The harness will hard-stop at 12 minutes, so if
you blow past 11 the self-report will be lost. If
unsolved when the budget is hit, save partial progress and report.
Budget the required diagnostic step early — do it before you sink time
into a proof, not after.

## Final output

When finished (whether solved, partial, or out-of-budget), output
exactly one JSON block as your last message, in this schema:

```json
{
  "problem_id": "1991.A5",
  "condition": "forced_inline",
  "outcome": "solved" | "partial" | "failed" | "timeout",
  "sorries_remaining": <int>,
  "tool_calls_total": <int>,
  "tool_calls_viz": <int>,
  "viz_read_back": true | false,
  "viz_verdict": "<the one-sentence verdict from the required step>",
  "viz_changed_approach": true | false,
  "decisive_tool": "<tool name or null>",
  "notes": "<one sentence: what worked, or where you got stuck>"
}
```
