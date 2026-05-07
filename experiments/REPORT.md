# A/B Experiment Report — Visualization Tools on Putnam Formalization

Run window: 2026-05-05 21:04 → 2026-05-06 22:55 (local).
Source data: `experiments/results/` (120 attempt directories, one
`meta.json` per attempt).

## Setup recap

- 20 Putnam problems (1985–2023), 2 conditions, 3 runs each = 120
  attempts.
- **Condition A** (control): `lean-lsp-mcp` only.
- **Condition B** (treatment): `lean-lsp-mcp` + `math-viz` (the full
  plotting / drawing toolkit).
- Per attempt: 10-minute hard wall-clock budget, 50 tool-call soft
  budget, fresh workspace with a Mathlib-pre-built `.lake` symlink.
- Scoring rule: an attempt is **solved** iff `lake build` succeeded
  *and* the produced `Solution.lean` contains zero `sorry`s. Anything
  else (partial proof with `sorry`, build failure, missing file) is
  unsolved, regardless of the model's self-report.

## Headline numbers

| Condition | N | Solved | Rate | `build_ok` | Timed out (10 min) | Mean wall (s) | Mean tool calls |
|-----------|---|-------:|-----:|-----------:|-------------------:|--------------:|----------------:|
| A (lean-lsp only) | 60 | **19** | **31.7%** | 58 | 16 | 649 | 11.4 |
| B (lean-lsp + math-viz) | 60 | **17** | **28.3%** | 57 | 12 | 467 | 11.9 |

**Visualization tools did not improve formalization success.** B's
solve rate is statistically indistinguishable from A's — and is
slightly lower in point estimate. With N=60 per arm, the 95% binomial
CI on each rate is roughly ±12 pts, so the 3.4-pt gap is well inside
noise.

The effect we set out to measure either does not exist at this scale,
or is dominated by a much larger confound described in the next
section.

## The dominant finding: math-viz was never invoked

> **In all 60 condition-B runs, the model issued zero `tool_use`
> blocks for any `mcp__math-viz__*` tool.**

We verified this two ways:
1. `meta.json::tool_counts` — no key starting with `mcp__math-viz__`
   in any of the 60 B records.
2. Re-walking every `tool_use` block in every B-run
   `claude_stdout.json` and counting names — also zero.

Self-reports agree: the `tool_calls_viz` field of the JSON the model
emits at the end of each B run summed to **0** across all 46 runs that
produced a self-report.

The pre-existing PNGs in `images/` (3 files) are dated 2026-05-05
**11:42–12:35** — i.e. ~9 hours before the first B run started
(21:04). They are leftovers from an earlier pilot, not output of this
sweep. The user's hypothesis that math-viz returned base64-encoded
images instead of writing files isn't supported: there are no
`tool_use` calls of any kind to that server, encoded or not.

So condition B effectively reduced to "lean-lsp only, with extra
unused tools advertised in the prompt." That this differs at all from
condition A is itself surprising — likely just sampling noise plus
small differences in tool-mention budget in the prompt.

## Per-problem breakdown (solved out of 3 runs)

| Problem | A | B | Category | Tags |
|---------|---|---|---------|------|
| 1985.B5 | 0/3 | 0/3 | graph-friendly | integral-evaluation |
| 1986.A1 | 3/3 | 3/3 | not | differentiability |
| 1987.B1 | 3/3 | 2/3 | graph-friendly | integral-evaluation |
| 1989.A2 | 0/3 | 0/3 | graph-friendly | integral-evaluation |
| 1991.A5 | 2/3 | 3/3 | graph-friendly | integral-evaluation |
| 1993.A1 | 3/3 | 1/3 | graph-friendly | integral-evaluation |
| 1994.A1 | 3/3 | 2/3 | not | limit-series \| convergence |
| 1995.A5 | 0/3 | 0/3 | graph-friendly | ode \| asymptotic |
| 1996.B2 | 0/3 | 0/3 | graph-friendly | asymptotic \| integral-inequality |
| 2000.A1 | 0/3 | 2/3 | not | convergence \| limit-series |
| 2002.A1 | 0/3 | 0/3 | not | differentiability |
| 2003.B2 | 0/3 | 0/3 | graph-friendly | limit-sequence \| asymptotic |
| 2004.A1 | 3/3 | 3/3 | not | continuity |
| 2006.A1 | 0/3 | 0/3 | graph-friendly | integral-evaluation |
| 2014.A3 | 0/3 | 0/3 | not | limit-sequence |
| 2015.A1 | 0/3 | 0/3 | graph-friendly | integral-evaluation |
| 2015.B1 | 0/3 | 0/3 | not | differentiability |
| 2018.A3 | 0/3 | 0/3 | not | differentiability |
| 2022.A1 | 2/3 | 1/3 | not | differentiability |
| 2023.A1 | 0/3 | 0/3 | not | differentiability |

Problems solved at least once: A=7, B=8. The set is almost
identical — `{1986.A1, 1987.B1, 1991.A5, 1993.A1, 1994.A1, 2004.A1,
2022.A1}` is solved in both arms. Only **2000.A1** was solved by B
and not A; in that case the winning B run used pure
`lean_diagnostic_messages` + `leansearch`/`loogle` interaction with no
plotting at all.

The `graph-friendly` tag (problems we expected to benefit from
visualization) made no difference: B did not pull ahead on that
subset.

13 of 20 problems were never solved by either arm — these are the
hard / specialized ones (asymptotic estimates, ODE bounds, hard
differentiability constructions). Visualization wasn't going to
rescue them anyway, but the sample is heavily weighted toward the
unsolvable end of the difficulty distribution.

## Failure mode: "build OK, but with one `sorry`"

The most common non-solved outcome in both arms was a file that
*compiles* but contains exactly one `sorry`:

| Condition | Solved (no sorry) | Built with `sorry` (always = 1) | Build failed | No file |
|-----------|------------------:|--------------------------------:|-------------:|--------:|
| A | 19 | 39 | 2 | 0 |
| B | 17 | 40 | 3 | 0 |

This is a direct artifact of the prompt: it explicitly tells the
model that "if the budget runs out, a `theorem … := by sorry` is an
acceptable fallback **for the proof**, but the answer term is not
optional." So when stuck, the model writes the spec + answer term and
stubs the proof. Almost two-thirds of all 120 attempts ended this
way. That's good news for partial-credit grading on the answer term,
but it means most of the runs aren't actually exercising the proof
loop — which is where visualization tools could plausibly help.

## Tool-call profile

Aggregated `tool_use` attempts across all 60 runs of each arm:

| Tool | A | B |
|------|--:|--:|
| Bash | 318 | 293 |
| Write | 98 | 94 |
| Read | 86 | 102 |
| `lean_diagnostic_messages` | 70 | 58 |
| ToolSearch | 41 | 49 |
| Edit | 21 | 33 |
| `lean_leansearch` | 12 | 32 |
| `lean_loogle` | 12 | 21 |
| `lean_local_search` | 2 | 16 |
| `lean_multi_attempt` | 3 | 0 |
| `mcp__math-viz__*` | n/a (denied) | **0** |

B used Mathlib-search tools (`leansearch`, `loogle`, `local_search`)
substantially more than A — 69 vs 26 calls. That's the most visible
difference between the two arms, and it has nothing to do with
visualization. Plausible explanation: a longer "tools you may use"
section in the B prompt may have nudged the model toward using more
of the lean-lsp toolkit, since math-viz never displaced anything.

The most-cited `decisive_tool` in B self-reports was
`lean_diagnostic_messages` (11 of 46 reports), then `lake build` (6).
No B self-report named a math-viz tool as decisive.

## Self-report vs. ground truth

The model's own outcome label disagrees with the harness:

| Condition | Self-reported "solved" | Actually solved | Self-reported "partial" | No self-report |
|-----------|----------------------:|----------------:|------------------------:|---------------:|
| A | 8 | 19 | 37 | 15 |
| B | 12 | 17 | 34 | 14 |

In A, the model is *under*-confident: it called many actually-solved
runs "partial". In B, the model is roughly calibrated. ~14 runs per
arm produced no self-report at all (they ran out of wall-clock or
tool-call budget before emitting the closing JSON block).

Lesson: don't trust `self_report.outcome`. Score off `build_ok &&
sorries_remaining == 0`, as we did.

## Why didn't B use math-viz?

Plausible explanations, in order of how likely they look from the
data:

1. **Prompt framing.** The prompt says: "There is no requirement to
   use the visualization tools — use them only if you find them
   genuinely useful." For tasks the model is approaching like
   formalization-by-direct-translation (read the LaTeX → write the
   theorem → ask `lean_diagnostic_messages` → patch), it never
   reached a point where a plot felt necessary.
2. **Time pressure.** With a 10-minute hard budget and a 9-minute
   wrap-up window, exploratory plotting feels expensive. The runs
   that did finish a proof did it by tight iteration with the Lean
   server, not by stepping back.
3. **Problem distribution.** Most of these problems aren't naturally
   "look at it and see the answer" problems even for humans — they
   need a clever inequality or a bijection. The handful that *might*
   benefit (1985.B5 area-of-region, 1996.B2 envelope behaviour) all
   fell into the "no one solved them" bucket where visualization was
   unlikely to be a single-step rescue anyway.
4. **No demonstration / nudge.** The prompt advertises math-viz but
   doesn't show an example of when to reach for it. The model
   defaults to its strongest known workflow.

## Caveats and threats to validity

- **N is small.** 60 attempts per arm gives roughly a ±12-pt 95% CI
  on a 30% solve rate. We can't detect effects smaller than that.
- **Ten-minute budget is tight.** The model timed out (`SIGTERM`-ed
  by the harness) on 16/60 A and 12/60 B runs. Some of those might
  have solved with more time.
- **The treatment was effectively never delivered.** The B arm
  doesn't actually test "what happens when the model uses
  visualization"; it tests "what happens when visualization is
  available but unused." A re-run that *forces* at least one math-viz
  call before declaring partial would test the actual hypothesis.
- **Difficulty skew.** 13 of 20 problems were never solved in either
  arm. These contribute zero signal to A-vs-B comparison; they only
  drag both rates down.
- **Self-reports are partial (76%/77% coverage).** The
  `tool_calls_viz` self-report figure is therefore a lower bound, but
  the transcript-level count (0) is exhaustive.
- **`Bash` was allowed for `lake build`, but a model could in
  principle plot via Bash + matplotlib.** We didn't audit Bash
  invocations for that. None of the visible Bash calls in the
  inspected runs did this, but it's a hole if you want to claim "no
  visualization happened anywhere."

## Suggested follow-ups

Ranked by what they'd actually clarify:

1. **Force the treatment.** Add a clause in the B prompt like:
   "Before writing your final `Solution.lean`, you must call at least
   one math-viz tool to inspect the problem geometry." Re-run on the
   same 20 problems. This actually measures whether the visualization
   helps, instead of measuring whether the model *chooses* it (which
   we now know it doesn't).
2. **Reweight the manifest.** Drop the never-solved problems and add
   more in the "occasionally solved" sweet spot
   (1991.A5 / 1993.A1 / 2000.A1 / 2022.A1 territory) where small
   differences in approach plausibly flip 1/3 → 3/3.
3. **Loosen the budget.** Try 25–30 min on the harder problems. If
   the model still doesn't touch math-viz at 30 min, that's a much
   stronger negative result than at 10 min.
4. **Add a math-viz primer to the B prompt.** A one-paragraph example
   ("for problems involving regions, integrals, or piecewise
   behaviour, plotting the integrand or boundary often makes the
   right inequality obvious") tests whether the issue is *capability*
   vs *prompting*.
5. **Audit Bash.** Make sure no condition is sneaking in Python
   plotting via Bash; tighten the deny list if so.

## Postscript — why math-viz never fired (concrete mechanism)

After the first pass of this report, two hypotheses were raised:
(a) the model never actually "saw" the pictures it was producing in
the manual pilot — it was the *user* doing the seeing, in real time;
(b) the manual pilot prompt made math-viz salient in a way the
harness prompt does not.

The pilot tool-usage log (`pilot/solutions/A2_log.md`, step 6)
documents the mechanism directly:

> `math-viz` writes a PNG and returns a path; I have to open it
> to actually see anything.

So `math-viz` does **not** return an image content block. It returns
a filesystem path as text. To actually consume the picture the model
must follow up with a `Read` on the PNG. In the A-2 pilot the model
plotted, then immediately read the PNG, then reasoned about it
("the orange parabola is above sin almost everywhere — original
theorem is false"). That two-step plot-then-Read sequence is the
treatment that worked.

Several harness-only frictions push against that sequence:

1. **No demonstration in the prompt.** The B template advertises
   math-viz in a flat tool list; it does not show the
   plot → Read → reason loop or motivate it. The pilot session
   started with the user asking "sanity-check the problem" — an
   instruction the harness prompt does not contain.
2. **Output-path ambiguity.** `math-viz` writes to a global
   `images/` directory under the repo root, *outside* each run's
   sandboxed workspace. The B prompt confines `Read` to "files in
   this working directory only (and viewing PNGs that `math-viz`
   writes to its image directory)" — but the carve-out is in
   parentheses and easy to miss. A model that takes the working-
   directory restriction at face value will conclude the PNGs aren't
   readable and skip the plot-then-Read pattern entirely.
3. **No human in the loop to nudge.** In `--print` mode the model
   emits one rollout end-to-end. There's no user message saying
   "look at the picture" mid-run. The model has to pre-decide both
   halves of the loop on its own, and apparently it doesn't.
4. **Time pressure.** A 10-minute budget plus the
   "no requirement to use" disclaimer in the prompt biases away from
   exploratory steps. In a manual session the user absorbs the
   exploration cost; in `--print` mode the model amortizes it
   against its own clock.

This reframes the negative result. **The experiment didn't measure
"does visualization help"; it measured "does an unattended Claude in
print mode discover a two-step plot-then-Read workflow from a flat
tool list under time pressure" — and the answer there is no.** With
the manual pilot already showing visualization producing decisive
findings (1985 A-2: discovered the original theorem was *false*,
flipped the entire approach), the right next experiment is to make
the workflow explicit, not to abandon the hypothesis.

Concrete prompt edits that would test the actual hypothesis:

- Promote the carve-out: change "(and viewing PNGs that `math-viz`
  writes to its image directory)" to a top-level bullet —
  *"After every `math-viz` call, `Read` the returned PNG path; the
  tool only returns a path, not the image."*
- Add a worked mini-example of the plot → Read → conclude loop
  ("e.g. for an integral inequality, plot both sides and read the
  PNG; if one is everywhere above the other, you have your direction
  of inequality").
- For the strongest test: require at least one `math-viz` call
  followed by a `Read` of the produced PNG before the final JSON
  block.

## TL;DR

- Math-viz was never invoked in 60 condition-B runs.
- Solve rates: A 31.7%, B 28.3% — within noise.
- Most attempts produced a compiling-but-`sorry`-stubbed file because
  the prompt explicitly allowed that as a fallback.
- The experiment as run did not test the visualization-helps
  hypothesis; it tested whether the model voluntarily reaches for
  visualization, and the answer is no.
