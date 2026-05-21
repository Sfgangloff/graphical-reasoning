# Research plan — visualization & autonomous-agent tools

Living document. Captures every direction we've identified, the
experiment that would test it, the prerequisites, and the order to
do them in. Updated as studies land.

## 0. What is already settled (Studies 1–3, n=147+54)

- **Adoption is governed by *requirement*, not *information*.**
  Across 174 unattended print-mode runs and three input framings,
  voluntary `math-viz` invocation is ~6–11%; full read-back of the
  returned PNG is 0%. Forced invocation hits 100% / 100%.
- **The `Read`-the-PNG second step is never self-discovered.** Every
  spontaneous viz call across `b` and `vizprimed` (3/36) was followed
  by zero `Read`s of the returned PNG path.
- **On the Lean-formalization task with a true-claim corpus, forced
  viz does not change `solved*` outcomes** (33% / 28% / 33% across
  `b` / `vizprimed` / `forced`). It does eliminate the
  "no plausible theorem" failure mode (18/18 statement-match vs.
  17/18 and 16/18 in the optional arms).
- **In all 18 forced runs, viz fires *first* (before any
  `Solution.lean` Write) and produces zero "surprise" language in the
  verdict.** Every verdict ratifies a closed form the model already
  had from reading the LaTeX. The plot performs no thinking work.
- **In all interactive pilot sessions, viz *did* perform decisive
  work** (2025 A-2: plot revealed the stated theorem was false). The
  difference is not the tool but the working pattern.

## 1. Open questions

In order of how important answering them is:

- **Q1 (information uptake).** When the model uses a plot, does it
  actually process the *image* — or has it learned to mimic the
  "humans sanity-check with pictures" behavior textually, using the
  picture only as a ceremonial token? *This is the deepest question.*
- **Q2 (corrective mode).** Does autonomous forced viz ever catch a
  false stated claim — the pilot's killer use case — when given the
  opportunity?
- **Q3 (problem type).** Does adoption and value rise on problems
  where visualization is intrinsically required (geometry,
  combinatorial figures, regions)?
- **Q4 (output format).** Is the Lean-formalization task itself the
  thing that drowns viz value, by making the proof/build loop the
  binding constraint? Does prose math reasoning expose value that
  Lean formalization can't?
- **Q5 (path-indirection friction).** Is the path→`Read` failure
  specific to images, or general to any tool that returns a path
  to content?
- **Q6 (baseline headroom).** Did our corpus simply have no room for
  viz to add value because the model already memorized the answers?
  This is the most banal explanation and must be ruled in or out
  first.

## 2. Studies to run

### Study 4 — diagnostic foundation (cheap, must be first)

#### 4a. Baseline closed-form recall — DONE  → answers Q6

Result: **strict 4/18 (22%), generous 7/18 (39%)**. Per problem
(generous): 1985.B5 1/3, 1989.A2 2/3 (with heavy hedging), 1991.A5
0/3 (parsing failure — the model treated "find the max" as a yes/no
and said "true" all three times), 1993.A1 1/3, 1996.B2 2/3,
2006.A1 1/3.

Calibration is decent: 4 of the 5 "high-confidence" answers across
all 18 runs are correct. So the model knows when it knows; it just
often doesn't, in a single shot.

**The "no headroom" hypothesis is rejected.** Single-shot recall is
~30%, while Study 3's Lean runs achieved ~80% answer-term match in
the optional arms (`b` 14/18, `vizprimed` 16/18) and 100% in `forced`
(18/18). So *something* in the multi-turn Lean rollout takes the
model from ~30% → ~80% match — and the data shows that *something*
is **not** `math-viz` (viz invocation in `b` is ~6%; in `vizprimed`
~11%; both arms still hit 14–16/18 statement match). Candidates:
extra reasoning time, `lake build` feedback, `lean_diagnostic_messages`
calls, or simply chain-of-thought via the act of writing.

This reframes Study 3's apparent null. The actual numbers:

| Setting | Answer-term correctness |
|---|---|
| Single-shot prose, no tools  | ~30% (4–7 / 18) |
| Multi-turn Lean, no forced viz (`b`, `vizprimed`)  | ~80% (14–16 / 18) |
| Multi-turn Lean, **forced viz** (`forced`)  | **100% (18/18)** |

So forced viz contributes a small but real ~15–20-percentage-point
lift in answer-term reliability on top of the much larger lift from
the multi-turn Lean process itself. The paper has been understating
this. The right statement is: *most of the answer-term reliability
gain comes from the multi-turn rollout, not from visualization;
visualization adds a small additional consistency effect by
eliminating the "no plausible theorem at all" failure mode*.

Caveat: the recall test was single-shot with no chain-of-thought
prompting ("memory only"). A fairer comparison would allow prose
reasoning. Run as 4a' below.

#### 4a'. Recall with reasoning — DONE

Result: **18/18 (100%) correct, all high confidence**. Just allowing
prose chain-of-thought (no tools) takes recall from ~30% single-shot
to **100%** with 20–120 s of reasoning per problem.

This **changes the diagnosis fundamentally**. The picture across the
three conditions we now have:

| Setting | Tools | Reasoning | Answer-term correct |
|---|---|---|---|
| Single-shot prose, no CoT  | none | none | ~30% (4–7 / 18) |
| **CoT prose, no tools** | **none** | **multi-paragraph** | **100% (18 / 18)** |
| Lean multi-turn (`b` / `vizprimed`)  | lean-lsp + viz available, ≤11% used | implicit via writing | ~80% (14–16 / 18) |
| Lean multi-turn, **forced viz** | viz at 100% / 100% read-back | implicit + forced pause | 100% (18 / 18) |

The dominant variable is *reasoning depth*, not tool availability.
Letting the model think uninterrupted in prose beats every
tool-mediated condition we have run. Tools (including forced viz)
add **at most a small consistency effect** on top of reasoning.

This reframes the entire research program. The original question
("do visualization tools help?") was confounded by reasoning depth.
The cleaner question is: **for problems where CoT alone *fails*,
do tools help?** That requires either harder problems (where the
model's CoT lands on the wrong answer) or adversarial framing
(false stated claims that bias CoT toward agreement).

The 2025 A-2 pilot fits this exactly: the file *asserted* a false
bound, the model's natural CoT would tend to ratify the assertion,
and the plot is what created the friction to overturn it. So the
condition under which viz is decisive is precisely the condition we
have not yet tested: **a problem where CoT-alone would get it wrong**.

#### 4b. Image vs textual vs reflection ablation  → answers Q1

The single most important study. Three forced-loop variants on the
same problems used in Study 3, identical except for *what gets done*
during the required sanity-check step:

- **`forced_visual`** — plot the central object, `Read` the PNG,
  write a one-sentence verdict (the existing `forced` condition).
- **`forced_textual`** — evaluate the central object at ~10 test
  points (or compute key symbolic identities), write a one-sentence
  verdict. No plot.
- **`forced_reflection`** — write a one-sentence "is the stated claim
  plausible? what is your prior on the answer?" — no tool use at all.

All three are *required, first action, single-shot* — identical
structurally; only the activity varies.

Predicted outcomes table:

| Observation | Conclusion |
|---|---|
| Verdicts/outcomes equal across all three | Picture and numerics both decorative; the act of forced pause is the only thing happening. |
| `forced_textual` ≈ `forced_visual` > `forced_reflection` | Numerical commitment is the driver; pictures add nothing. |
| `forced_visual` > `forced_textual` | Image information is genuinely being processed and used. |
| `forced_visual` < `forced_textual` | The image is *worse* than the numerics it would be derived from — possibly a confound (picture interpretation costs tokens and time, numerics don't). |

This is the most informative single experiment in the entire program.
A clean 3-arm ablation, n=18/arm (6 problems × 3 runs), 54 cells —
same budget as Study 3.

### Study 5 — corpus, claim-truth, and format axes

Three orthogonal design changes; each removes one of the structural
limits of Study 3. Best done as a single factorial study rather than
three separate ones.

#### 5a. Geometric corpus  → answers Q3

Curate ~6 problems that are *intrinsically geometric* — Putnam or
otherwise: lattice-point counting, area-of-figure, conic intersection,
classical Euclidean, combinatorial-geometry, possibly a phase-portrait
ODE problem. The point is to choose problems where a figure is the
*primary tool* a competent human reaches for, not a secondary check.
Candidates to source: Putnam geometry problems we've not used (e.g.
1985 A-1 dodecahedron, 1989 A-3 region, 1992 B-3 cone, 2002 B-2
chord, 2008 A-4 region, 2010 A-1 grid), or off-corpus problems
(IMO geometry, classical olympiad).

#### 5b. False-claim variants  → answers Q2

For 2–3 problems in the geometric corpus (and 2–3 in the original
analytic corpus, as a comparison), create a *deliberately wrong*
variant: flip an inequality direction, perturb a constant, or replace
the stated answer with a near-miss. Run under the same three
conditions (`b`, `vizprimed`, `forced`). Two separate framings:

- **Covert**: the problem text just says "show ...". Tests whether the
  model spontaneously catches a falsehood in passing.
- **Explicit**: the problem text says "prove X" where X is in fact
  false. The natural reading triggers sanity-checking; the question
  is whether the *tool* is what does the catching.

Outcome of interest: did `forced` (or `forced_visual` from 4b) ever
produce a verdict containing "false", "wrong", "incorrect", or
equivalent that *reversed* the answer term?

#### 5c. Prose vs. Lean output  → answers Q4

For each (problem, condition), additionally run a prose-output arm:
the deliverable is a prose math answer with brief justification, not
a Lean file. Scored on correctness against the canonical answer (the
existing judge generalizes if we adapt the prompt). Removes Lean as
a confound.

Combined Study 5 design (full factorial): 6 problems × 2 corpora
(analytic / geometric) × 2 truth (true / false) × 3 conditions × 2
output formats × 3 runs = a lot. Realistic version: pick the
2-3 most informative slices and run those; do not try the full
factorial. My pick:

- 6 geometric problems × 3 conditions × 3 runs in prose output, with
  3 of them quietly modified to false claims. 54 cells. Same budget
  as Study 3.

### Study 6 — generalize beyond visualization  → answers Q5

A non-visual tool that returns *a path to a file containing the
result* instead of returning the result inline. Concrete design: a
small `math-compute` wrapper that writes a numerical or symbolic
result to a JSON file under `images/` (sharing the path-not-content
mechanic) and returns the path. Two forced conditions:

- **`forced_inline`** — same tool, but it returns the value as text.
- **`forced_path`** — same tool, but it returns a filesystem path
  that the agent must `Read` to consume.

If read-back is < 100% in `forced_path`, the path-not-content friction
is general; if it's 100%, viz is uniquely afflicted (perhaps because
images are perceived as "something to look at later" rather than
"a value to consume now"). 6 problems × 2 conditions × 3 runs = 36
cells. Smaller than the visualization studies.

This study also has the side benefit of being a clean
agent-tool-design contribution: future MCP tools should return
content inline whenever possible, not paths to content.

### Loop-structure axis (cross-cutting, can be folded into 4b or 5)

Single-shot vs. iterative requirement. Each of the forced variants
above can be tested as "do it once" vs. "do it, then look at the
result, then do another check" (a multi-step loop required by the
prompt). The pilot's working pattern was iterative; one-shot may be
the floor of what's possible.

## 3. Repository / publication question

`math-viz` (and `lean-lsp-mcp`) live in a separate repo
[`math-reasoning-tools`](https://github.com/Sfgangloff/math-reasoning-tools).
For a paper claiming things about *these specific tools*, we need
reproducibility. Three options, in order of effort:

1. **Submodule + pinned commit.** Add `math-reasoning-tools` as a
   git submodule at a specific commit hash. Lowest effort, standard.
   Drawback: the reader still needs to set up the MCP server.
2. **Vendor a snapshot in the supplementary archive.** Include the
   tool source as a tarball with the paper artifact. Self-contained.
3. **Companion artifact paper / open-source release.** If
   `math-reasoning-tools` is on track to be a usable, generalizable
   thing, publish it as a separate artifact (tool paper / system
   demonstration). Highest effort, highest impact.

Recommended for v1 of this paper: do (1) immediately (one-line repo
change), commit to (2) as part of the submission archive. (3) is a
separate decision.

A minimum bar regardless: every tool we use must have its **name,
version, and behaviour documented** in the paper appendix, including
the path-not-content mechanic that turned out to be load-bearing.

## 4. Prioritized order

The cheapest highest-information move is the foundation; each subsequent
study builds on what the previous one established.

**Revised priorities after 4a/4a':**

| Step | Study | Why | Compute |
|---|---|---|---|
| ✓ | 4a recall, 4a' CoT recall | Done. Established reasoning-depth dominance. | done |
| **1** | **5b False-claim study** | Now the highest-priority experiment. The condition under which viz is decisive is precisely where *CoT alone would get it wrong*. False stated claims operationalize this. | ~Study-3 scale |
| 2 | **4b Image-vs-textual-vs-reflection ablation** | When viz IS forced and does seem to help, is it the picture, the numerics, or the pause? Strongest predicted outcome now: on true-claim problems, all three arms produce indistinguishable results (because CoT alone suffices); only on false-claim problems does the image potentially diverge. **Fold into 5b** so each false-claim problem is run under (forced_visual, forced_textual, forced_reflection) — a 3-arm test on a corpus where the answer matters. | merge w/ 5b |
| 3 | **5a Geometric corpus** | Worth its own arm in 5b — geometric problems are where pictures plausibly carry information CoT alone can't reach. Curate 3 truly geometric + 3 analytic problems, run both true and false variants. | combined in 5b |
| 4 | **6 Path-indirection generalization** | Bonus result broadening to tool design generally. Worth doing but lower priority than the false-claim test. | ~24 cells |
| 5 | **5c Prose vs Lean output** | The recall test is essentially the "prose, no tools" baseline already. Adding "prose, with tools" would test whether tools help in the output format they were designed for. Cheaper than the Lean studies; can be done. | ~18 cells |

The new centerpiece study folds 4b + 5a + 5b into one design:

> **Study 5 (revised) — adversarial sanity check.**
> Corpus: 6 problems (3 geometric, 3 analytic), each run in two
> variants: true-as-stated and deliberately false (inequality
> flipped or constant perturbed). Conditions: `forced_visual`,
> `forced_textual` (compute test points instead of plotting),
> `forced_reflection` (just pause and write a one-sentence verdict).
> Output: prose answer (not Lean). Outcome: did the model catch the
> false claim, and which forced activity was responsible?
>
> Cells: 6 problems × 2 truth × 3 conditions × 3 runs = **108**.
> Half of Study 3's compute would be 54 cells (e.g. 6×2×3×3=108 but
> we can drop runs to k=2: **72 cells**).

This is the experiment that would settle whether autonomous forced
viz can be *corrective* (the pilot's killer use case), AND whether
the corrective work is the picture or the pause.

## 5. Paper trajectory

The current draft argues "advertised tools aren't adopted; required
loops are confirmatory, not corrective; the design space we explored
is structurally unable to detect viz value." With the studies above
done, the paper becomes:

> We map the design space for evaluating visualization tools in
> autonomous LLM agents along four orthogonal axes (output format,
> problem type, claim truth, tool return type), show that the most
> obvious operationalization is structurally unable to detect viz
> value, identify two distinct failure modes (the path-not-content
> friction and the ratification-not-thinking pattern), and report
> remedial designs that successfully exhibit autonomous corrective
> use when at least three axes are properly chosen. We further
> demonstrate via a 3-arm ablation that, when the model does engage
> with a forced sanity-check, *most of the measured value comes from
> the act of pausing and committing to numerical evidence*, not from
> the image per se — a finding that generalizes to MCP-tool design
> beyond visualization.

The four axes + the three failure modes + the ablation are the
contribution. The negative result is the lede; the remedial designs
are the payoff.
