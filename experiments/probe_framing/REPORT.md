# Framing probe — does Lean framing surface general-purpose tools?

Run window: 2026-05-08 (27 attempts). Prompted by the followup
observation in `experiments/REPORT.md`: anecdotally, problems
presented in Lean syntax seem to pull in `math-viz` and
`math-compute` calls that prose framings of the same problem do
not. This probe tests whether that effect survives a controlled
A/B/C across three framings.

## Setup

- **3 problems**: 1985 B-5, 1989 A-2, 1996 B-2 (the three integral /
  asymptotic problems already exercised in the main A/B sweep).
- **3 framings** (the only variable):
  - `probe_prose` — workspace contains the LaTeX excerpt; prompt
    points at it. No mention of available math tools beyond a
    "Tools you may use" list.
  - `probe_nudge` — same as `probe_prose`, plus an explicit "use
    the available tools (visualization, symbolic computation,
    Lean introspection) as appropriate" line.
  - `probe_lean` — workspace contains a `Theorem.lean` stub with
    the theorem signature and `:= sorry`; prompt asks to fill in
    the answer term and replace `sorry`. No LaTeX excerpt is
    delivered; the problem is presented purely as Lean syntax.
- **Tool surface held constant**: all three framings expose the
  same 75 inner-Claude tools (14 `math-viz`, 11 `math-compute`,
  23 `lean-lsp-mcp`, plus host tools). Verified by inspecting the
  `system: init` event in each `claude_stdout.json`.
- 3 runs per cell × 9 cells = 27 attempts. 10-min wall budget,
  80-call soft budget — same as the main study.
- Output is Lean in all three cases (`Solution.lean`); the
  variable is the *input* presentation only.

## Headline numbers

Mean tool calls (succeeded) per attempt, by family, aggregated
across all three problems:

| framing      | n | lean | viz | compute | host | total | runs w/viz | runs w/compute |
|--------------|---|-----:|----:|--------:|-----:|------:|-----------:|---------------:|
| probe_prose  | 9 |  0.3 | 0.0 |     0.6 |  8.1 |   9.0 |   **0/9**  |          3/9   |
| probe_nudge  | 9 |  0.3 | 0.0 |     0.7 |  9.9 |  10.9 |   **0/9**  |          4/9   |
| probe_lean   | 9 |  0.1 | 0.0 |     0.3 |  6.9 |   7.3 |   **0/9**  |          3/9   |

Per-tool totals across all 9 runs of each framing:

```
=== probe_prose ===                === probe_nudge ===                === probe_lean ===
  31  Bash                            43  Bash                          26  Bash
  21  Read                            16  ToolSearch                    20  Read
  10  Write                           13  Read                           9  Write
   9  ToolSearch                      12  Write                          6  ToolSearch
   4  mcp__math-compute/sympy_eval     5  mcp__math-compute/sympy_eval   2  mcp__math-compute/sympy_eval
   3  mcp__lean-lsp/lean_diag_msgs     5  Monitor                        1  Monitor
   1  mcp__math-compute/sympy_integ    3  mcp__lean-lsp/lean_diag_msgs   1  mcp__math-compute/sympy_integ
   1  Monitor                          1  mcp__math-compute/sympy_integ  1  mcp__lean-lsp/lean_leansearch
   1  ScheduleWakeup
```

## Findings

### 1. The Lean-framing hypothesis is not supported

`math-viz` was invoked **zero times across all 27 runs**, in all
three framings. The earlier anecdotal observation ("Lean framing
pulls in viz tools too") does not replicate in this controlled
setting.

`math-compute` invocations are non-zero but small and *not* higher
under `probe_lean` — in fact the `probe_lean` cell has the lowest
compute usage of the three (3/9 vs 4/9, mean 0.3 vs 0.6–0.7).

### 2. Lean framing reduced overall tool reach, did not increase it

Mean total tool calls per attempt: prose 9.0, nudge 10.9, **lean
7.3**. The `probe_lean` model issued the *fewest* tool calls of any
arm. The plausible mechanism: when the problem arrives as a
typed Lean stub, the model treats it as a syntax-completion task
("fill in the closed form, then `by sorry`") and stops exploring
sooner. The first prose arm has to translate the LaTeX into a Lean
theorem signature, which itself induces extra Read/Edit/Bash
churn.

### 3. The "use tools" nudge moved activity, but not into viz

`probe_nudge` has the highest total tool count (10.9) and the
highest `compute` rate (4/9), but the gain is concentrated in
Bash (43 vs 31), ToolSearch (16 vs 9), and Monitor (5 vs 1) —
host tools the model uses to inspect its own state. The viz rate
is unchanged from prose: zero.

### 4. Lean-LSP usage is also nearly absent

Across 27 runs, the `lean-lsp-mcp` server received **7 calls
total** (6 `lean_diagnostic_messages`, 1 `lean_leansearch`). The
model's preferred Lean-feedback tool is `Bash → lake build`, not
the LSP. This holds under all three framings, including the one
where the problem *starts* as a Lean file.

## What this probe does and doesn't test

What it tests cleanly: holding tool availability and *output*
format constant (always Lean), does varying the *input* framing
between prose and Lean syntax change tool reach? Answer: no, or
slightly the wrong direction.

What it does **not** test: contexts where the output is *also*
prose. The original anecdotal observation may have been about
sessions where the model produces a Lean proof end-to-end versus
sessions where it answers a math question in prose. Those differ
on output expectations, not just input syntax. A future probe
could vary output: `prose problem → prose answer` vs `Lean stub →
Lean proof`, with the same tool surface and budget.

It also does not test interactive / multi-turn sessions. All 27
runs were one-shot `--print` invocations under a 10-minute
budget. The original observation may have come from a session
where the user kept the model in tool-use mode across several
turns. Section "Why didn't math-viz get used?" of the main
`experiments/REPORT.md` already flags one-shot mode as a
structural bias against tool exploration; this probe is consistent
with that.

## Implications for the next viz study

- **Do not factor input framing into the next experiment.** The
  Lean vs prose vs nudge axis explains essentially zero variance
  in viz invocation (it is zero everywhere). Designing a 2×2 over
  framing × viz-allowed would be wasted budget.
- **The remaining real variable is what the prompt
  *requires*.** `experiments/REPORT.md` already proposes the right
  test: make at least one `math-viz` call followed by a `Read` of
  the produced PNG a *requirement*, not an option. The probe data
  reinforces this — adding "use tools as appropriate" nudges
  raises Bash/Monitor activity but not viz, so soft language is
  not enough.
- **Lean-LSP under-use is a separate, larger finding** worth
  flagging on its own. Models in `--print` mode appear to prefer
  `lake build` over LSP queries by an order of magnitude. If the
  goal is to evaluate Mathlib proof workflows, this is the
  bottleneck — not viz.

## TL;DR

Across 27 runs, three framings of the same three problems, with
identical tool surfaces:

- math-viz invocations: **0 in every framing**.
- math-compute invocations: 3–7 calls total per framing (small).
- Lean framing did not surface more tools; it surfaced fewer.
- The follow-up section of `experiments/REPORT.md` should be
  updated: input framing is not the lever. Prompt-level
  requirement (or session shape) is.
