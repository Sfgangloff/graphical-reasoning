# Do visualization tools help an LLM agent solve Putnam problems? A negative result, and what it actually measures

**Draft — 2026-05-21.** Studies 1–5 complete: 147 forced/optional
print-mode runs, 36 recall probes, 48 adversarial cells. Headline
matrix §8.1, interpretive reframe §8.2, final adversarial test §9.

---

## Abstract

A competent human's first move on many analysis problems is to *draw
something*: sketch the integrand, plot both sides of an inequality,
look at the asymptotics. We ask whether giving the same affordance to
an autonomous LLM coding agent — Claude Code with MCP plotting tools
(`math-viz`) — changes what it can solve, on a corpus of
statement-level Lean 4 / Mathlib formalizations of Putnam
real-analysis problems (1985–2025).

**Across 147 unattended `--print`-mode runs spanning a 120-attempt
A/B sweep and a 27-attempt input-framing probe, the agent invoked a
visualization tool exactly zero times**, including on the
integral/asymptotic subset most amenable to a picture; solve rates
were statistically indistinguishable between arms (31.7% vs 28.3%).
Yet in *manual, interactive* pilot sessions the same model used the
same tools and the use was decisive — in one case a single plot
revealed the stated theorem was false. The experiments did not
measure *does visualization help*; they measured *does an unattended
one-shot agent spontaneously discover a two-step plot-then-read-back
workflow under time pressure*, and that answer is robustly no.

Three follow-up studies isolate what the value actually depends on.
Study 3 (54 attempts) *requires* the loop: adoption goes 10% → 100%
with full PNG read-back, but solve rates do not move — on a corpus of
true claims the delivered visualization is confirmatory only. Study 4
(36 attempts) compares against zero-tool prose CoT alone: multi-
paragraph CoT recovers the same 100% answer-term correctness as forced
viz, so the corpus has no CoT-incompetence headroom for any tool to
demonstrate value. Study 5 (48 attempts) constructs the missing
adversarial corpus — *deliberately mis-stated* canonical answers —
and runs a three-arm forced ablation: required visualization (7/8),
required numerical check (8/8), and required tool-free prose
reflection (7/8) catch false claims at indistinguishable rates.
**The corrective work is the required verification step, not the
modality that satisfies it; visualization is sufficient but not
necessary.** The methodological generalization:
voluntary-use evaluations of advertised agent tools conflate tool
value with tool discovery, and unattended evaluations on a corpus
where the model's CoT already suffices cannot detect the value of any
tool at all.

---

## 1. Introduction

The motivating hypothesis is simple. If a strong human's first move on
"find the largest constant such that one curve sits below another," or
"evaluate this integral," is to sketch the objects involved, then an
LLM agent with a plotting tool should (a) reach for it and (b) solve
more, or solve differently. This repository is a test harness for that
hypothesis, built on a curated substrate: statement-level Lean 4 /
Mathlib formalizations of every real-analysis problem from the Putnam
Competition, 1985–2025.

What we found instead is a clean negative — but a *structured* one,
whose structure is the actual contribution. The negative is not "the
tools don't help." It is "an unattended agent never invokes them," and
those are very different claims with very different implications for
how anyone should evaluate agent tooling.

## 2. Background: the substrate and the tools

**Corpus.** Each Putnam problem is delivered to the agent as a
natural-language LaTeX excerpt; the deliverable is a `Solution.lean`
that (i) states the problem as a Lean theorem, (ii) supplies a typed
closed-form answer term where the problem says "Evaluate/Find/Compute,"
and (iii) proves it. Scoring is mechanical: an attempt is *solved* iff
`lake build` succeeds, `Solution.lean` contains zero `sorry`s, and an
independent LLM judge rates the statement a faithful match to the
LaTeX. The closed-form *answer term* is judged separately from the
proof, which matters below.

**Tools.** `lean-lsp-mcp` exposes proof-state inspection, Mathlib
search, and diagnostics. `math-viz` exposes plotting and diagram
rendering (`plot_function`, `plot_implicit`, `plot_region`,
`plot_phase_portrait`, `draw_graph`, …). A crucial implementation
detail: **`math-viz` tools do not return an image content block. They
write a PNG to disk and return its filesystem path as text.** To
consume a plot the agent must take a second, separate step — `Read`
the returned path. This two-step structure is central to the result.

## 3. Experimental setup

Per attempt: a fresh workspace with a pre-built Mathlib `.lake`
symlinked in; the reference formalizations locked unreadable; a
per-condition `.claude/settings.json` controlling the tool surface; a
hard wall-clock budget; `claude --print --output-format stream-json`
invoked once from the workspace. Every `tool_use` block in the
transcript is counted, with permission denials and runtime errors
excluded from "succeeded" totals. *k* ≥ 3 independent runs per
(problem, condition) cell.

## 4. Study 1 — the A/B sweep (120 attempts)

20 Putnam problems (1985–2023), 2 conditions, 3 runs each.

- **Condition A** (control): `lean-lsp-mcp` only.
- **Condition B** (treatment): `lean-lsp-mcp` + `math-viz` (full
  toolkit).
- 10-minute hard budget; 50-tool-call soft budget.

### 4.1 Headline numbers

| Condition | N | Solved | Rate | `build_ok` | Timed out | Mean wall (s) | Mean tool calls |
|-----------|---|-------:|-----:|-----------:|----------:|--------------:|----------------:|
| A (lean-lsp only) | 60 | 19 | **31.7%** | 58 | 16 | 649 | 11.4 |
| B (+ math-viz)    | 60 | 17 | **28.3%** | 57 | 12 | 467 | 11.9 |

With N=60/arm the 95% binomial CI on each rate is ≈ ±12 pts; the
3.4-pt gap is well inside noise. Visualization availability did not
improve formalization success.

### 4.2 The dominant finding: the treatment was never delivered

> **In all 60 condition-B runs, the agent issued zero `tool_use`
> blocks for any `mcp__math-viz__*` tool.**

Verified two independent ways (the `meta.json` tool counter and a
re-walk of every `tool_use` block in every transcript) and corroborated
by the agent's own end-of-run self-reports (`tool_calls_viz` summed to
0). Condition B therefore reduced to "Condition A with extra unused
tools advertised in the prompt." The `graph-friendly` problem tag
(problems we pre-classified as picture-amenable: integral evaluation,
asymptotics, regions) produced no B advantage on its subset.

### 4.3 The confound that ate the experiment

Roughly two-thirds of all 120 attempts ended as a file that *compiles
but contains exactly one `sorry`* — a direct artifact of the prompt
explicitly allowing `theorem … := by sorry` as a fallback for the
proof while requiring the answer term. So most runs never exercised
the proof loop, which is one place visualization might help; and 13 of
20 problems were never solved by either arm, contributing zero
A-vs-B signal while dragging both rates down.

## 5. Study 2 — input-framing probe (27 attempts)

An anecdotal follow-up observation suggested that problems presented
as Lean syntax (rather than prose) might pull in general-purpose math
tools that prose framings did not. We tested 3 problems × 3 framings
(prose / prose+nudge / Lean stub) × 3 runs, tool surface held constant
(`lean-lsp` + `math-viz` + `math-compute`).

- **`math-viz` was invoked zero times across all 27 runs, in every
  framing.** The Lean-framing hypothesis did not replicate.
- Mean total tool calls: prose 9.0, prose+nudge 10.9, Lean stub 7.3.
  The Lean stub framing *reduced* tool reach (the agent treats a typed
  stub as a syntax-completion task and explores less).
- A soft "use the available tools as appropriate" nudge raised Bash,
  `ToolSearch`, and self-monitoring activity but moved viz invocation
  not at all (still zero).
- Incidental but important: `lean-lsp-mcp` itself received **7 calls
  total across 27 runs**. The agent's preferred Lean-feedback channel
  in print mode is `Bash → lake build`, by an order of magnitude over
  LSP queries — independent of framing.

Conclusion: input framing is not the lever, and soft prompting is not
enough. The only untried lever is what the prompt *requires*.

## 6. The positive control: manual pilot sessions

The capability and the value of visualization are not in doubt — they
are documented in interactive pilot sessions on Putnam 2025 A-2 and
B-2, run under the same restricted tool surface but *with a human in
the loop across turns*.

On 2025 A-2, the agent's recorded tool log shows it plotted
`sin x`, `(4/π²)·x·(π−x)`, and `(1/π)·x·(π−x)` on `[0, π]`, then
`Read` the produced PNGs, and concluded: the parabola the formalization
claimed as a lower bound is actually *above* `sin` almost everywhere —
**the stated theorem was false.** The agent's own assessment: this
"flipped my entire approach… without these I would have spent a long
time trying to prove a false theorem." A second plot pinned the
corrected extremal constants numerically. This is an existence proof
that the plot→`Read`→reason loop, when executed, is decisive — and
that its highest-value use is *diagnostic* (is the claim even true?
what is the closed form?), which sits squarely on the critical path
for the answer term.

The pilot log also states the mechanism in one line: *"`math-viz`
writes a PNG and returns a path; I have to open it to actually see
anything."* The decisive treatment is two steps, and the second step
(`Read`) must be self-initiated.

## 7. Synthesis: what was actually measured

The contrast is the result. Same model, same tools, same problems:
decisive in interactive mode, never invoked in unattended print mode.
The experiments did not measure *does visualization help*; they
measured *does an unattended agent in one-shot print mode spontaneously
discover and execute a two-step plot-then-read-back workflow under a
10-minute clock with a "no requirement to use" disclaimer* — and that
answer is robustly no across 147 runs, 3 input framings, and the
picture-amenable subset.

Four mechanisms plausibly contribute: no mid-rollout nudge to switch
workflows (in interactive sessions the human supplies one); path-not-
image friction (the `Read`-the-PNG step is buried in a parenthetical
that contradicts the prompt's "files in this working directory only");
time pressure under opt-out language; and a task confound (the
sorry-stub fallback meant most runs never exercised the proof loop,
where viz might otherwise help). Study 3 below pins which of these
are the binding constraint.

## 8. Study 3 — forcing the treatment

To measure the value term we must remove the discovery term. Study 3
holds the corpus to the six viz-friendly integral/asymptotic problems
where the pilot showed visualization is decisive for the answer term
(1985.B5, 1989.A2, 1991.A5, 1993.A1, 1996.B2, 2006.A1) and varies only
the prompt across three conditions, 3 runs each (54 attempts, 12-min
budget, identical tool surface `lean-lsp` + `math-viz`):

- **`b`** — the original flat "viz available, optional" prompt
  (control; expected ≈ 0 viz, reproducing Studies 1–2).
- **`vizprimed`** — viz still *optional*, but the two harness frictions
  are removed: a top-level statement that `math-viz` returns a path the
  agent must `Read` (and is permitted to, anywhere), plus a worked
  plot→`Read`→conclude primer. Isolates the *tool-description /
  framing* hypothesis.
- **`forced`** — the plot→`Read`→one-sentence-verdict loop on the
  problem's central object is a hard *requirement* before the final
  `Solution.lean`. Converts the dead variable into a live one.

This 3-arm design separates the candidate explanations cleanly:

| Observation | Implies |
|---|---|
| `vizprimed` ≈ `b` ≈ 0 viz, `forced` > 0 | soft prompting can't fix it; only a hard requirement delivers the treatment |
| `vizprimed` > `b` | the path-not-image / framing friction was the lever |
| `forced` improves build/answer-term over `b` | visualization, when executed, has measurable value on this task |
| `forced` viz fires but outcomes unchanged | the diagnostic value seen in the pilot does not transfer to autonomous use, or the task confound (sorry-stub) masks it |

Primary measured outcomes: viz-invocation rate; PNG read-back rate
(the loop's second step, detected from the transcript); `build_ok`;
`sorries == 0`; statement-match judge verdict; and, for the forced
arm, a self-reported one-sentence verdict and whether the picture
changed the approach.

### 8.1 Results (full 54-cell matrix)

All six viz-friendly problems (1985.B5, 1989.A2, 1991.A5, 1993.A1,
1996.B2, 2006.A1) completed three runs of each of the three prompt
conditions for **54 attempts total**. Every attempt was independently
LLM-judged for statement faithfulness to the LaTeX problem.

**Per-condition aggregate (n = 18 runs/arm):**

| Condition | viz/run | % w/viz | % PNG read-back | build_ok | sorries=0 | solved* | judge (match/close/mis/non-stmt) |
|-----------|--------:|--------:|----------------:|---------:|----------:|--------:|---------------------------------:|
| `b`         | 0.1 |   6% |   0% | 16/18 |  8/18 | 6/18 (33%) | 14 / 3 / 0 / 1 |
| `vizprimed` | 0.1 |  11% |   0% | 17/18 |  6/18 | 5/18 (28%) | 16 / 0 / 0 / 2 |
| `forced`    | 1.4 | **100%** | **100%** | 17/18 |  7/18 | 6/18 (33%) | **18 / 0 / 0 / 0** |

`solved*` = `build_ok ∧ sorries=0 ∧ judge ∈ {match, close}`.

**Per-cell `% w/viz` highlights:** `forced` fires 3/3 with full PNG
read-back on every one of the 6 problems. `vizprimed` voluntary viz
is concentrated on **2006.A1** (the torus-volume problem, the most
visually geometric in the set: 2/3 there, 0/3 everywhere else).
`b` has one stray invocation, on **1989.A2** (1/3). Neither `b` nor
`vizprimed` ever follows up with a `Read` of the PNG — voluntary
plots are *never* read back.

Three findings, on the full 54-cell dataset:

1. **Adoption is governed by *requirement*, not *information*.**
   `vizprimed` (path-not-image friction removed, `Read`-the-PNG
   carve-out promoted, worked plot→`Read`→conclude primer added, viz
   still *optional*) moved voluntary invocation from 6% → 11% — a
   negligible bump, both extra plots on 2006.A1, the single most
   visually geometric problem. By contrast, `forced` lifts invocation
   to **100%** universally with **100%** PNG read-back, every run,
   every problem. The 3 spontaneous viz calls across `b` + `vizprimed`
   were *never* followed by a `Read` of the returned PNG: the loop's
   second step is never self-discovered. Tool descriptions are not the
   lever — requirement is, and the agent complies with it cleanly.
2. **Forced viz does not change build/sorry outcomes.** `solved*`
   rates are statistically indistinguishable across all three arms
   (`b` 33%, `vizprimed` 28%, `forced` 33%; binomial 95% CI ≈ ±23 pts
   at n=18). The agent self-reported `viz_changed_approach = false`
   in **0/18** forced runs. Yet the `viz_verdict` self-report shows
   the loop did real work every time: in every forced run the agent
   plotted the central object, numerically validated a test case
   against the conjectured closed form, and committed the answer term
   with stated confidence — √(π/a)·e^{−2a} (1985.B5),
   (e^{a²b²}−1)/(ab) (1989.A2), max = 1/3 (1991.A5), Pappus → 6π²
   (2006.A1), and the directional sandwich (1996.B2). So forced viz
   reliably *de-risks the answer term* but, on this corpus, never
   reverses an approach. The visualization is *confirmatory only*.
3. **A small, real quality effect on statement faithfulness.**
   Forced viz produced **18/18 "match" verdicts** with no
   non-statements; `b` and `vizprimed` produced 1 and 2
   "non-statement" outcomes respectively (failures to write any
   plausible theorem). The required plot→`Read`→one-sentence-verdict
   loop appears to force the agent to commit to a concrete answer
   term before writing the file, eliminating the worst failure mode.
   Tiny effect in absolute terms but it is the only build/sorry/judge
   column where `forced` is strictly best.

**The corrective mode did not fire — but had no opportunity to.** The
pilot's decisive episode (2025 A-2: plot reveals the stated theorem
is false, agent reverses course) did not recur in any of the 18
`forced` runs. The single best candidate was 1996.B2, whose stated
sandwich inequality
`((2n−1)/e)^{(2n−1)/2} < 1·3·5⋯(2n−1) < ((2n+1)/e)^{(2n+1)/2}`
is the kind of asymptotic claim a plot would catch if misoriented.
The agent's forced verdicts for 1996.B2 all read essentially:
"the stated sandwich inequality is TRUE and correctly oriented for
all n ≥ 1." So the plot *did* perform the corrective check — it just
came back with no correction to make, because the inequality is
correct. **None of the 6 problems contained a false or
mis-oriented stated claim**, so this experiment cannot distinguish
"autonomous forced viz never corrects" from "there was nothing to
correct." A future study with one or two deliberately false claims
would close this gap. The behavior we observe is consistent with the
pilot model — confirmatory verdicts on true claims, corrective
verdicts on false ones — but this study delivers only the former
half of that prediction.

**Net.** The full 54-cell dataset closes the loop on the prompt-level
levers and leaves a single, sharply specified open question:

- *Adoption*: governed by requirement; descriptions/framing are not
  the lever. (Settled.)
- *Compliance*: forced loops work perfectly in unattended print mode.
  (Settled.)
- *Outcome value, true-claim corpus*: confirmatory only, no
  build/sorry effect, but eliminates the "non-statement" failure
  mode. (Settled.)
- *Outcome value, false-claim corpus*: untested here; the pilot
  shows it can be dramatic. (Open — requires a deliberately
  mis-stated problem in the test set.)

### 8.2 Diagnostic: how much of the Study-3 effect is reasoning, not tools?

Study 3 measured the increment from advertised → required viz inside
a fixed multi-turn Lean rollout. But the multi-turn rollout *itself*
gives the model time to reason. To separate the contribution of
reasoning depth from the contribution of tool use, we ran two
zero-tool prose probes on the same 6 problems (k = 3 per problem):

- **4a (single-shot recall).** "State the closed-form answer from
  memory. Two lines: `ANSWER:` and `CONFIDENCE:`. No tools, no
  prose reasoning."
- **4a' (CoT recall).** Identical setup *except*: "You may reason
  step by step in prose for as long as you like before answering.
  Still no tools."

Both prompts give the agent only `Read` access to the LaTeX excerpt.
No `lean-lsp`, no `math-viz`, no `Bash`, no Lean output expected.

Results, against the canonical answers from the reference
formalizations:

| Setting | Tools | Reasoning | Answer-term correct (n=18) |
|---|---|---|---|
| **4a — single-shot prose** | none | none | ~30% (4 strict, 7 generous) |
| **4a' — CoT prose** | **none** | **multi-paragraph** | **100% (18/18)** |
| Study 3, `b` / `vizprimed` (Lean) | viz available, ≤11% used; lean-lsp available, rarely used | implicit via writing | ~80% (14–16 / 18) |
| Study 3, `forced` (Lean) | viz 100% / 100% read-back | implicit + forced pause | 100% (18 / 18) |

**The dominant variable is reasoning depth, not tool availability.**
Twenty seconds to ~two minutes of uninterrupted prose CoT, with no
tools at all, recovers the same answer-term correctness as a 10-minute
Lean multi-turn rollout *with* forced visualization. The Study-3
arms that the §8.1 table reports as "no `solved*` effect" sit between
these two ceilings: the multi-turn Lean process pulls performance
from ~30% to ~80% via something other than viz (extra deliberation
time, the act of writing, `lake build` feedback), and forced viz adds
a further ~15–20 percentage points to *answer-term consistency* (no
non-statements) on top of that.

This reframes the whole study. The original framing — *advertised viz
isn't adopted; forced viz is confirmatory only* — remains correct,
but it understates what was actually going on. The cleaner statement
is:

> For problems where CoT alone suffices, *no tool can show a value
> effect, because there is no headroom left to capture*. The Study-3
> corpus consists entirely of such problems (CoT-recall 18/18). Any
> viz value our experiment could in principle have detected would
> have come from problems where CoT alone *fails* — i.e. genuinely
> harder ones, or problems with deliberately mis-stated claims that
> bias CoT toward an incorrect ratification. Neither of those was in
> our corpus.

The pilot's decisive 2025 A-2 episode fits this exactly: the file
asserted a false bound, the natural CoT would tend to ratify the
assertion (and indeed the human who wrote the formalization did so),
and the plot is what created the friction to overturn it. The
condition under which forced viz is most plausibly decisive — the
condition our experiment never set up — is precisely **a problem
where CoT-alone gets it wrong**.

A separate methodological consequence, applicable far beyond
visualization: **agent-tool evaluations on a corpus where the
model's CoT suffices cannot detect the value of any tool, because
there is no error for the tool to correct.** Study-3-style designs
implicitly require a baseline of CoT-incompetence to be interpretable;
ours had a CoT baseline of 100%.

## 9. Study 5 — adversarial sanity check (false-claim ablation)

§8.2 left a sharp open question: would forced visualization beat
zero-tool prose CoT on the *one* class of problem where CoT plausibly
fails — when the stated answer is wrong and CoT would tend to ratify
it? Finding genuinely CoT-incompetent Putnam problems is itself a
hard search problem; the cheapest way to engineer the condition is to
*deliberately mis-state* the canonical answer in problems the agent
would otherwise solve.

From the §8.1 corpus we take the four analytic / integral problems
whose canonical answer is easy to perturb cleanly: 1985.B5, 1991.A5,
1993.A1, 1996.B2. For each, the agent is shown a LaTeX excerpt
asserting a closed-form answer that *may or may not* be correct, and
must commit to a verdict (`correct` / `incorrect`) plus a stated
correct answer. Two variants of each problem:

- **`true`** — the canonical Putnam answer (√(π/a)·e^{−2a}, 1/3, 4/9,
  the canonical 1·3·5⋯(2n−1) sandwich).
- **`false`** — a plausibly-wrong substitute. e^{−a} instead of
  e^{−2a}; 1/4 instead of 1/3; 2/9 instead of 4/9; the sandwich
  inequality with bounds *reversed* in direction.

Three forced-verification conditions, each requiring a different
*modality* of pre-verdict check, n = 2 runs per cell (4 × 2 × 3 × 2 =
48 cells; 12-min budget; identical excerpt source; identical
final-JSON schema across arms):

- **`forced_visual`** — must call a `math-viz` tool on the central
  object and `Read` the returned PNG before emitting a one-sentence
  verdict comparing the picture to the claim. No `math-compute`.
- **`forced_textual`** — must call `math-compute` (SymPy) to evaluate
  the claim at sample points before emitting a one-sentence verdict
  comparing the numbers to the claim. No `math-viz`.
- **`forced_reflection`** — must produce a one-paragraph prose
  argument about whether the claim is correct before emitting the
  verdict. *No tools at all.*

This three-arm design separates "the required-verification step does
the work" from "*which modality* of verification does the work."

### 9.1 Results (48-cell matrix)

Per (condition × variant) aggregate (n = 8 per row):

| Condition | Variant | n | CORRECT | WRONG_V | V_OK_A_X | MISS | viz/r | comp/r |
|---|---|---:|---:|---:|---:|---:|---:|---:|
| `forced_visual`     | true  | 8 | 8 | 0 | 0 | 0 | 2.6 | 0.0 |
| `forced_visual`     | false | 8 | 7 | 0 | 0 | 1 | 2.0 | 0.0 |
| `forced_textual`    | true  | 8 | 8 | 0 | 0 | 0 | 0.0 | 6.8 |
| `forced_textual`    | false | 8 | 8 | 0 | 0 | 0 | 0.0 | 6.9 |
| `forced_reflection` | true  | 8 | 8 | 0 | 0 | 0 | 0.0 | 0.0 |
| `forced_reflection` | false | 8 | 7 | 0 | 0 | 1 | 0.0 | 0.0 |

Grade key: `CORRECT` = the agent's verdict matches ground truth *and*
(on the false variant) the stated `correct_answer` matches the
canonical closed form to a regex check. `WRONG_V` = wrong verdict.
`V_OK_A_X` = verdict right but the corrected answer is wrong.
`MISS` = no verdict emitted.

Headline — false claims caught per condition (across all four
problems):

| Condition | Caught | Per-problem |
|---|---:|---|
| `forced_textual`    | **8 / 8** | B5 2/2, A5 2/2, A1 2/2, B2 2/2 |
| `forced_visual`     | 7 / 8 | B5 1/2, A5 2/2, A1 2/2, B2 2/2 |
| `forced_reflection` | 7 / 8 | B5 2/2, A5 2/2, A1 2/2, B2 1/2 |

The two `MISS` cells are operational losses, not anchoring failures:
`forced_visual` 1985.B5 r1 was a 30-second run that produced no
self-report JSON (transcript-parse failure on a degenerate output);
`forced_reflection` 1996.B2 r0 hit the 12-min wall-clock budget
without emitting a final JSON. **No cell that emitted a verdict ever
sided with the false claim** (`WRONG_VERDICT` = 0 across all 48 cells;
`V_OK_A_X` = 0 also).

### 9.2 The agent never actually looked at the pictures

A behavioral footnote that changes how the `forced_visual` row should
be read: across the 16 `forced_visual` cells (true + false), the
PNG-read-back rate was **0%**. The prompt explicitly required the loop
*plot → `Read` the returned PNG → state verdict*, but in every run the
agent skipped step 2 — it called `math-viz` (2× on average), then
went directly to the verdict without ever issuing a `Read` on the
returned PNG path.

Yet the `viz_verdict` text is *grounded*. Sample (1985.B5 false r0):

> Shaded integrand for a=1 gives ≈ 0.2399, which matches √π·e^{−2},
> not the claimed √π·e^{−1} ≈ 0.6522.

The numerical value `0.2399` does not come from the picture; it comes
from the textual / JSON return of `plot_integrand_with_shading`, which
(like most `math-viz` tools) returns numerical metadata alongside the
PNG path. So `forced_visual` in this study reduced, behaviorally, to
*forced numerical-metadata-via-viz-tool*. The agent did not "see" a
plot; it parsed numbers from a tool that happened to also write a
PNG.

This is the §8.1 path-not-image failure mode reappearing in a slightly
different shape: even with an explicit prompt requirement to `Read`
the PNG, the agent declines, because the tool's text return already
gives it enough to answer. We did not observe this in §8.1 because
there the harness's worked-example primer and the heavier framing
("a plot you never `Read` tells you nothing") were enough to elicit
compliance; here the shorter prompt was not. The print-mode agent's
default is to use the cheapest information channel that works, and a
text channel always works.

### 9.3 What the result says

1. **The forced verification step works on adversarial inputs.** Every
   emitted verdict was correct. Anchoring on the stated wrong answer
   — the failure mode this study was constructed to elicit — was
   never observed in any cell, in any condition. This is the pilot's
   predicted corrective mode, finally exercised: when the stated claim
   is false, the agent overturns it.
2. **Modality doesn't matter.** Visual (8/8 true, 7/8 false, with the
   one miss a transcript-parse failure), textual numerical (8/8, 8/8),
   and pure prose reflection (8/8, 7/8, with the one miss a timeout)
   are statistically indistinguishable. The cheapest modality — pure
   prose reflection with *no tools at all* — recovers essentially all
   of the corrective benefit. This sharpens §8.2: not only is
   reasoning depth the dominant variable on CoT-easy problems, but on
   *adversarial* problems as well.
3. **The lever is the required commitment to a verification step,
   not its modality.** All three conditions structurally force the
   agent to commit to a verdict frame *before* emitting an answer.
   That structural constraint — *check the claim before ratifying it*
   — is what defeats anchoring. The picture, the SymPy check, and the
   pause are *interchangeable* ways to satisfy the constraint.
4. **The visualization tool's image channel still goes unused.** Even
   when the prompt explicitly required PNG read-back, the agent used
   the tool's text return and skipped the image. So *forced
   visualization* in print mode, prompt-only, is not actually
   delivering image inspection; it is delivering "you called a viz
   tool, which happens to return some numbers." The picture is dead
   even in conditions designed to bring it alive.

### 9.4 Net effect on the paper's central claim

Study 5 was the test the program needed to either rescue or close out
the "forced visualization has unique value" hypothesis, and the result
closes it. The pilot's 2025 A-2 episode remains a clean
*interactive*-mode demonstration that the picture *can* be decisive,
but on the present evidence a forced numeric check or a forced prose
argument would equally well have done the work. The actionable lever
is **session shape and verification structure**, not tool catalogue.

## 10. Threats to validity

- **N is modest.** ±12-pt CI on Study-1 rates; Study 3 is powered for
  the *binary* "does the agent comply when required" and for large
  answer-term effects, not for small solve-rate differences.
- **Corpus skew.** 13/20 unsolved-by-anyone problems contribute no
  A-vs-B signal. Study 3 deliberately restricts to the tractable
  viz-friendly subset to recover signal, at the cost of generality.
- **The forced design measures a different estimand.** "Does mandatory
  viz help" is weaker than "does viz help when the agent judges it
  useful." The pilot suggests the high-value use is diagnostic;
  `forced` operationalizes exactly that diagnostic step, which
  mitigates but does not eliminate the gap.
- **Bash escape hatch.** `Bash` is permitted for `lake build`; an
  agent could in principle plot via Python+matplotlib through Bash.
  No inspected run did, but "no visualization anywhere" is asserted
  only for MCP `math-viz` calls.
- **Self-reports are partial** (≈ 76% coverage in Study 1); all
  invocation counts are taken from the exhaustive transcript walk, not
  self-reports.
- **Study 5 is small (n = 2 per cell).** The 7/8 vs 8/8 vs 7/8 split
  across the three conditions is well inside the binomial noise band
  at n = 8 (95% CI ≈ ±25 pts), so the conclusion is *no detectable
  modality advantage*, not *equality demonstrated*. The result rules
  out the strong claim "forced visualization uniquely catches false
  claims that other forced verification cannot," but does not rule
  out a small modality-specific edge a larger N could detect.
- **Study 5's adversarial corpus is narrow.** Four analytic / integral
  / asymptotic problems, all of whose canonical answers are
  perturbable to a single scalar or a flipped inequality direction.
  Adversarial conditions where the picture might out-perform numerics
  or prose — geometric problems with a hard-to-numerically-sample
  region, or claims about a global shape (monotonicity, convexity)
  that a single SymPy sample misses — are not represented.

## 11. Related framing

This is an instance of a general agent-evaluation pitfall: advertising
a tool in the prompt and measuring downstream task performance
estimates *tool value × P(tool adopted | prompt, mode)*. Interactive
and autonomous one-shot modes differ enormously in the second factor.
Benchmarks that compare "agent with tool X" vs "agent without tool X"
on end-task accuracy, without verifying invocation, may be reporting
adoption failures as capability ceilings.

## 12. Conclusions and next steps

1. Visualization tools were never invoked by an unattended print-mode
   agent across 147 runs, despite documented decisive value in
   interactive use. The negative is about *adoption*, not *value*.
2. Input framing and soft nudging do not move adoption off zero;
   prompt-level requirement (or interactive session shape) is the only
   lever that moves it.
3. Study 3 measures the value term directly by forcing the loop.
   Result: requirement lifts viz adoption from ~10% to 100% with
   100% PNG read-back. Outcomes (`solved*`) are indistinguishable
   across arms (33% / 28% / 33%); forced viz eliminates the
   "no plausible theorem" failure mode (statement-match 18/18 vs
   14–16/18 for the optional arms) but does not change build/sorry.
4. **The most important finding, identified via diagnostic Study 4a':
   reasoning depth is the dominant variable.** Allowing the model
   20–120 seconds of uninterrupted prose chain-of-thought, with **no
   tools at all**, recovers the same answer-term correctness (18/18,
   100%) as a 10-minute Lean rollout with forced visualization. The
   Study 3 corpus consists entirely of problems where CoT-alone is
   already 100% correct — there was no headroom for any tool to
   demonstrate value. The dominant signal across the entire research
   program (147 forced/optional cells + 36 recall probes + 48
   adversarial cells, §9) is that
   *autonomous-mode agent tools cannot be evaluated on a corpus
   where the model's CoT already suffices*. This generalizes beyond
   visualization to any agent-tool study.
5. Study 5 (§9) tests the condition where forced viz is most plausibly
   decisive — *a deliberately false stated claim*. Required
   visualization, required numerical check, and required tool-free
   prose reflection catch the lie at indistinguishable rates (7/8,
   8/8, 7/8; the two non-catches are operational losses, not
   ratifications). The corrective work is **the required pause and
   commitment to verify**, not the picture and not the numerics;
   visualization is sufficient but not necessary. A side finding from
   the same study: even when the prompt explicitly required PNG
   `Read`, the agent skipped it and used the viz tool's text return.
6. Two independent design issues identified along the way are worth
   reporting on their own:
   - **Path-not-content friction.** `math-viz` returns a path; the
     agent never self-discovers the `Read` second step (0 / 3
     spontaneous viz calls were read back). This is a clean MCP-tool-
     design lesson and is plausibly general to any tool returning
     references rather than inline content.
   - **Session shape.** Across 174 unattended print-mode runs,
     `lean-lsp-mcp` received well under one call per run on average;
     the agent defaults to `Bash → lake build` regardless of input
     framing or available tools. If the goal is evaluating MCP-tool-
     assisted reasoning at all, the binding constraint is *session
     shape*, not the tool catalogue.

---

### Reproducibility

- Studies 1–2: `experiments/REPORT.md`,
  `experiments/probe_framing/REPORT.md`; runner in
  `experiments/runner/`.
- Pilot positive control: `pilot/solutions/A2_log.md` (tool-by-tool
  log), `pilot/solutions/A2_solution.lean`.
- Study 3: `experiments/forced_viz/run_forced.py` (driver),
  `analyze_forced.py` (aggregation), prompt templates
  `experiments/prompts/condition_{b,vizprimed,forced}.template.md`.
- Study 4 (recall probes): `experiments/recall_test/run_recall.py`
  (single-shot, 4a) and `run_recall_cot.py` (CoT, 4a').
- Study 5 (adversarial false-claim ablation, §9):
  `experiments/false_claim/run_false_claim.py` (driver),
  `analyze_false_claim.py` (aggregation), canonical-answer patterns in
  `experiments/false_claim/canonical.json`, true/false excerpts under
  `experiments/false_claim/excerpts/`, prompt templates
  `experiments/false_claim/prompts/forced_{visual,textual,reflection}.template.md`.
