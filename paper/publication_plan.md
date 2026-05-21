# Publication plan — AAAI 2027 main track

**Status:** committed plan, 2026-05-21.
**Target venue:** AAAI 2027 main track.
**Hard deadline:** AAAI 2027 abstract deadline ~2026-08-08, full paper
~2026-08-15 (check the call when it opens; assume mid-August).
**Today minus deadline:** ~13 weeks.
**Compute budget:** Anthropic Max subscription only (no other API spend).
**Backup venues (if Aug submission slips):** NAACL 2027 main/Findings
(Oct 2026), COLM 2027 (Mar 2027).

## 1. The paper this plan is aiming at

A 7-page archival paper titled, draftily, *"Discovery dominates value:
why advertised visualization tools go unused by an autonomous LLM agent,
and what to do about it."* Single contribution split into three legs:

1. **The discovery-value decomposition** (framing contribution). For
   an advertised but optional agent tool, the measurable end-task
   effect is `tool_value × P(tool_adopted | prompt, mode)`; in
   unattended print mode the adoption term can be identically zero,
   making the value term unmeasurable from voluntary-use designs. We
   name this and instantiate it with Claude Code + `math-viz`.
2. **The empirical landscape** (negative-result contribution).
   147-run A/B sweep + 27-run framing probe + 54-run forced-loop study
   + 36-run zero-tool recall + an n=6-per-cell adversarial false-claim
   ablation (Study 6, this campaign) + an n=5-per-cell geometric
   adversarial corpus (Study 8). Modality doesn't matter when a
   verification step is *required*; the picture is sufficient but not
   necessary.
3. **A constructive design recommendation** (positive contribution).
   The `math-viz` path-returning interface systematically suppresses
   voluntary adoption. Returning inline-content lifts adoption from
   ~10% to (target: ≥40%) without changing the underlying model
   (Study 7, this campaign). This is a generalizable MCP-tool-design
   lesson.

**Single-model scoping.** The paper is honest from the abstract
forward that all results are with the Claude family in `--print` mode.
The methodological caveat is positioned as "for at least one frontier
LLM agent, the discovery-vs-value confound is dominant — a sufficient
existence case to motivate the methodology."

## 2. The 13-week schedule

Calendar weeks counted from 2026-05-21. The plan parallelizes
human-attention work (corpus construction, judge audit, writing)
against background-running agent rollouts.

| Wk | Date range | What's happening |
|--:|---|---|
| 1 | 05-21 → 05-28 | Pre-reg on OSF (§4). Warm-up 20-cell batch on `math-viz` to confirm subscription rate-limit headroom. Start geometric corpus construction (§6). Begin LaTeX skeleton on AAAI template. |
| 2 | 05-29 → 06-04 | Study 6 (scale Study 5 to n=6/cell) launches in background. 96 new cells. Continue corpus construction. |
| 3 | 06-05 → 06-11 | Study 6 wraps. **Decision gate 1.** Begin Study 7 prep: fork math-reasoning-tools, add `--inline-content` mode. |
| 4 | 06-12 → 06-18 | Study 7 (inline-content ablation) launches. 144 cells. Geometric corpus finalized — 8 problems, 16 excerpts. |
| 5 | 06-19 → 06-25 | Study 7 finishes. **Decision gate 2.** Study 8 (geometric adversarial) launches. 240 cells. |
| 6 | 06-26 → 07-02 | Study 8 background-runs. Begin judge-audit sampling (§5). |
| 7 | 07-03 → 07-09 | Study 8 finishes. **Decision gate 3.** Judge audit underway — your 8 hours fall in this week. |
| 8 | 07-10 → 07-16 | Judge audit wraps. Compute Cohen's κ; if low, re-grade affected cells with 3-judge majority (background). Begin formal stats pass. |
| 9 | 07-17 → 07-23 | Formal stats done. Begin paper writing in earnest on AAAI LaTeX template. Figures drafted. |
| 10 | 07-24 → 07-30 | Full first draft of paper. |
| 11 | 07-31 → 08-06 | Internal review (1–2 outside readers). Revise. |
| 12 | 08-07 → 08-13 | Final revision pass + figure polish + appendix tidy. **Abstract submission ~08-08.** |
| 13 | 08-14 → 08-15 | Final submission. **Hard deadline ~08-15.** |

### Decision gates

- **Gate 1 (end Wk 3):** does the modality-doesn't-matter finding
  survive Study 6 at n=24/condition? If `forced_textual` still leads,
  the headline holds. If a modality wins decisively, reframe.
- **Gate 2 (end Wk 5):** does inline-content adoption beat path
  adoption by ≥15 absolute pts at p<0.05? If yes, the constructive
  contribution is locked. If no, demote Study 7 to a side-finding and
  lean harder on the methodological-decomposition framing.
- **Gate 3 (end Wk 7):** does `forced_visual` significantly out-catch
  `forced_textual` on the geometric corpus? If yes, the paper has a
  *positive* viz result and Section 5 of the paper changes
  accordingly. If no, the "modality doesn't matter" claim is much
  stronger for having survived a corpus designed to favor pictures.
  Either outcome is publishable — pick the framing the night the
  result lands, do not defer.

## 3. New studies launched in this campaign

### Study 6 — Scaled adversarial (Weeks 2–3)
Re-run Study 5 with n=6 runs per cell (was n=2). New cells:
`4 problems × 2 variants × 3 conditions × 4 additional runs = 96`.
Driver: `experiments/false_claim/run_false_claim.py` — already
configured. Update `auto_resume_state.json` to plan the extra 96.

### Study 7 — Inline-content tool design ablation (Weeks 3–5)
Fork `external/math-reasoning-tools`, modify `math-viz` so that each
plot tool *also* returns a `content` block containing the rendered PNG
as base64. Add a flag to the server config to toggle path-only vs
path+inline. New harness condition: 2×2 = {forced, optional} ×
{path-only, inline-content}. Run on the 6 Study-3 problems × 4
conditions × 6 runs = **144 cells**. Primary outcome: voluntary
adoption rate. Secondary outcome: in the inline-content arms, does
the agent's verdict text reference *image features* (curve crossings,
shape, slope visible) vs *metadata-only* features (numerical sample
values)? Qualitative coding on 20 transcripts.

### Study 8 — Geometric adversarial corpus (Weeks 5–7)
Run the three-arm forced ablation (`forced_visual` / `forced_textual`
/ `forced_reflection`) on the new geometric corpus from §6.
`8 problems × 2 variants × 3 conditions × 5 runs = 240 cells`.

## 4. Pre-registration (Week 1)

Before any new data is run, post a 2-page pre-registration document on
OSF (osf.io, free). Include:

- The exact hypotheses for Studies 6, 7, 8 in declarative form.
- Primary outcome metric + statistical test for each.
- Sample size + power justification.
- Decision rule (what counts as "significant" / "supports
  hypothesis").
- Stopping rule (no peeking, no early termination, no n adjustments
  after the fact).
- A pointer to this repo at the current commit.

Template to copy:

> **H6:** On the 4-problem false-claim corpus at n=6 runs/cell, the
> three forced verification conditions (`forced_visual`,
> `forced_textual`, `forced_reflection`) have indistinguishable
> false-claim catch rates. Test: Fisher's exact 3×2 contingency,
> α = 0.05. Decision rule: if no pairwise comparison reaches
> p < 0.05/3, the modality-doesn't-matter claim is supported.
>
> **H7a:** In the inline-content arm of Study 7, voluntary `math-viz`
> adoption is ≥ 15 absolute percentage points higher than in the
> path-only arm. Test: paired binomial across problems, α = 0.05.
>
> **H7b:** Conditional on adoption, agents in the inline-content arm
> reference image features in ≥ 50% of verdicts vs ≤ 20% in the
> path-only arm. Test: hand-coded transcripts of 20 random cells per
> arm; Fisher's exact.
>
> **H8:** On the geometric adversarial corpus, `forced_visual` catches
> false claims at a strictly higher rate than `forced_textual`
> (one-sided, α = 0.05). Test: paired binomial across the 8 problems.

Commit the pre-reg as `paper/pre_registration.md` in this repo *and*
upload to OSF on the same day. The OSF timestamp is the defensible
evidence.

## 5. Judge audit protocol — your 8 hours of hand-grading

### What this defeats
Reviewers will note that all verdicts are graded by an LLM judge that
shares failure modes with the agent under test. This audit provides
human-rater validation and lets us report Cohen's κ in the paper.

### Sample design
**Stratified random sample of 120 cells:**

| Source | New cells in scope | Sample to draw |
|---|---:|---:|
| Study 3 (forced viz, 54 existing) | 54 | 25 |
| Study 5 (false claim, 48 existing) | 48 | 20 |
| Study 6 (scaled adversarial, n=6) | 96 new | 30 |
| Study 7 (inline-content) | 144 new | 25 |
| Study 8 (geometric) | 240 new | 20 |
| **Total** | | **120** |

Within each stratum, sample uniformly at random by `tag` (the run
directory name). Use a fixed seed (42) so the sample is reproducible
and we can report it. Sampling script: write
`experiments/judge_audit/sample.py` once, point at each study's
results dir.

### What you grade per cell

For each sampled cell, you'll see four fields rendered side-by-side:

1. **The LaTeX excerpt** the agent was shown (1–10 lines).
2. **The canonical answer** from `canonical.json` or the geometric
   corpus's `canonical.json`.
3. **The agent's emitted `verdict` + `correct_answer`** strings from
   `meta.json → self_report`.
4. **The LLM judge's verdict** from `judge.json` (where applicable),
   or — for the false-claim style cells without a judge.json — the
   analyzer's `grade()` output.

You assign **one of three labels**:

- `CORRECT` — agent's verdict matches ground truth *and* (on `false`
  variants) the corrected answer is mathematically equivalent to the
  canonical answer, up to formatting.
- `WRONG` — agent's verdict disagrees with ground truth, or (on
  `false` variants) the corrected answer is mathematically wrong.
- `UNCLEAR` — the agent's output is malformed, missing, or genuinely
  ambiguous (e.g. the agent emitted "incorrect, the answer is
  somewhere between 1/3 and 1/2" — neither right nor demonstrably
  wrong).

### What I'll set up before you start
- `experiments/judge_audit/sample.py` — generates the 120-cell sample
  with seed 42 and dumps `sample.csv` with columns:
  `tag, study, excerpt_path, canonical, agent_verdict, agent_answer, judge_verdict, your_grade`.
- `experiments/judge_audit/grade.py` — interactive CLI: prints the
  four fields, prompts you to type `c` / `w` / `u`, writes your grade
  back to `sample.csv` row-by-row. Resumable if you stop mid-session.
- A `notes` field per row for the ones where you want to write a
  one-liner about why.

### How to execute the 8 hours
- Aim for **2 hours × 4 sessions** over 3 days. Concentration matters
  more than calendar speed; one fatigued 8-hour session degrades
  reliability.
- Pacing: 120 cells / 8 hours = **~4 minutes per cell**. Most are
  faster; the geometric ones are slower.
- Before starting, do a **calibration block of 10 cells** that I'll
  also pre-grade independently. Compare. If our κ on that block is
  < 0.7, talk through disagreements before you do the rest.
- Do not look at the LLM judge's verdict before deciding your own.
  The CLI shows your-grade-first, then reveals the judge.

### Statistics we'll report

- Cohen's κ between your grades and the LLM judge's grades, per study
  and overall. Target: κ ≥ 0.6 overall.
- Per-cell agreement %.
- The set of disagreement cells, listed in the appendix with one-line
  explanations.
- If κ < 0.6 on any study: switch that study's grades to a
  3-judge majority vote (LLM-judge + 2 different-prompted re-runs)
  before reporting any per-condition numbers from that study.

### Acceptance criteria
- 120 cells graded.
- κ ≥ 0.6 overall.
- All disagreements documented.
- All raw grades committed to the repo at `experiments/judge_audit/`.

## 6. Geometric adversarial corpus — exactly what to build

### The brief
8 problems, each with two LaTeX excerpts (`true` and `false`) and an
entry in `experiments/geometric_corpus/canonical.json`. The problem
must satisfy three properties:

1. **Picture-decisive**: the truth of the claim is visually obvious
   from a single well-chosen plot.
2. **Sampling-fragile**: a *naïve* SymPy sampling strategy at uniform
   grid points can be made to miss the falsifier.
3. **Concise**: the LaTeX excerpt is ≤ 15 lines.

### Problem types to use (pick 8 out of these 10)

For each type below, the *false* variant is the one stated. The
*true* variant flips the stated claim to match reality.

| # | Problem template | Why a picture wins | Why naïve SymPy misses |
|--:|---|---|---|
| 1 | "The curves f(x) = `sin(πx)` and g(x) = x²(2−x) are *equal at exactly one point* in [0,1]." | A plot shows they touch at one point and don't cross. | A uniform grid of 11 samples computes |f−g| ≥ ε everywhere; the tangency at ~0.69 is missed. |
| 2 | "The parametric curve (cos t, sin 2t), t∈[0,2π], has no self-intersections." | The figure-eight self-intersection at (0,0) is unmissable. | Sampling 50 points and checking pairwise distance < ε can miss the crossing if ε is small. |
| 3 | "The function f(x) = x⁴ − 2x² + 1 + 0.01·exp(−100(x−0.5)²) is convex on [−1,1]." | The plot of f'' shows a clear dip below 0 near x=0.5. | Sampling f'' at 0.0, 0.1, …, 1.0 misses the narrow dip near 0.5. |
| 4 | "The region {(x,y) : x² + y² ≤ 1, y ≥ sin(8x)/4} is simply connected." | The plot shows an island disconnected by the high-frequency sine. | Containment checks at uniform points hit only the main region. |
| 5 | "The sequence aₙ = 1/n + sin(n)/n² is monotonically decreasing for n ≥ 1." | The plot of aₙ shows a clear non-monotone wiggle around n=4–6. | Sampling aₙ−aₙ₊₁ at n=1, 5, 10, 50 can come out positive everywhere. |
| 6 | "On [0,1], f(x) = e^x − x − 1 ≥ g(x) = x²/2 + x³/10." | The plot shows f dips below g near x = 0.1. | A coarse SymPy `solve` for the crossing returns no real root in [0,1] due to numerical tolerance. |
| 7 | "The function f(x) = arctan(x) + arctan(1/x) is constant for x > 0." | One plot shows it's flat at π/2 — true variant. The false variant claims it's flat at π/4. | A SymPy sample at x=1 gives π/2 ≈ 1.5708; the false claim π/4 ≈ 0.7854 is caught trivially. (Drop this if too easy.) |
| 8 | "The implicit curve x³ + y³ = 3xy passes through (1,1) and (3/2, 3/2)." | A plot of the folium of Descartes shows (1,1) is not on it. | Direct substitution catches the falsifier instantly. (Drop this if too easy.) |
| 9 | "The function f(x) = x · sin(1/x), extended by f(0)=0, has a derivative at 0." | The plot near 0 shows the oscillation that prevents differentiability. | Numerical derivatives at fixed h miss the lim-doesn't-exist subtlety. |
| 10 | "The two surfaces z = x²+y² and z = 2 − x²−y² intersect in a single circle in 3-space." | A 3D plot shows the intersection clearly. | True, so this would be a `true` variant. Construct a false variant claiming they intersect in two circles, or in a point. |

**Recommendation:** use problems 1, 2, 3, 4, 5, 6, 9, 10. Drop 7 and 8 because the SymPy fix is too obvious.

### Concrete construction protocol per problem

For each chosen problem, deliverable is **four files**:

```
experiments/geometric_corpus/
├── canonical.json
├── excerpts/
│   ├── geom_01_true.tex
│   ├── geom_01_false.tex
│   ├── geom_02_true.tex
│   ├── geom_02_false.tex
│   ...
└── verify.py     # see below
```

Format of each `.tex` excerpt — follow the existing
`experiments/false_claim/excerpts/1985_B5_*.tex` style:

```
\begin{problem}[Geometric claim 01]
Consider $f(x) = \sin(\pi x)$ and $g(x) = x^2(2 - x)$ on $[0, 1]$.

\textbf{Claim.} The equations $f(x) = g(x)$ has \emph{exactly one
solution} in $[0, 1]$, and the curves cross at that point.
\end{problem}
```

(The true variant for problem 1 would change "cross" to "touch
without crossing"; only the structural part of the claim changes,
nothing else.)

Format of `canonical.json`:
```
{
  "geom_01": {
    "false_claim": "curves cross at the equality point",
    "true_claim":  "curves touch but do not cross",
    "canonical_evidence": "f − g has a double root at x ≈ 0.69, so they are tangent",
    "viz_check": "plot f and g on [0,1] together",
    "sympy_naive": "compute |f(x)−g(x)| at x = 0, 0.1, …, 1.0 and observe no sign change"
  },
  ...
}
```

### `verify.py` — confirm picture-decisive + sampling-fragile

For each problem, write a tiny verification script that:

1. Plots the central object via the same `math-viz` tool the agent
   would use (`plot_function`, `plot_implicit`, or `plot_parametric`).
2. Manually inspect: does the plot make the truth obvious in one
   glance? If no, redesign the problem.
3. Runs the "naïve SymPy sample" that `forced_textual` would
   plausibly run (sample 11 uniform points and report; or
   `sympy.solve` with default settings). Confirm the falsifier is
   missed.
4. Logs both results to `verify.log`.

This is the gate: if the picture isn't obviously decisive *to a human
who looks*, you've not constructed a true picture-decisive problem.
Redesign.

### Time budget for you
- 8 problems × ~45 min each (design + draft both variants + verify
  + iterate) = **~6 hours** total over a week.
- Spread across the week — interleave with running Study 6.

### Acceptance criteria
- 8 problems, each with `_true.tex`, `_false.tex`, `canonical.json`
  entry, and `verify.log` evidence that the picture is decisive and
  the naïve SymPy check misses.
- 2 problems independently verified by a second human (me or a
  colleague) as picture-decisive.

## 7. Risk register

| Risk | Likelihood | Mitigation |
|---|---|---|
| Rate limits hit on subscription during Study 8 | medium | Stagger runs across days; harness's auto_resume already handles partial completion. |
| `math-viz` fork to add inline-content turns out non-trivial | medium | Timebox to 3 days. If it fails, descope Study 7 to a side-finding ("we tried this and it broke the harness in interesting ways") and lean on the methodological-decomposition contribution. |
| Geometric corpus turns out *not* picture-decisive (SymPy catches all of them) | medium | This is a real failure mode. Acceptance criterion above forces detection early. If it happens, the paper's positive viz result evaporates — pivot Section 5 to "even on a corpus designed to favor pictures, modality doesn't matter" which is still publishable but different. |
| Judge audit shows κ < 0.5 on a study | low | Pre-budget Week 8 for the 3-judge majority re-grade fallback. |
| Decision-gate result reverses the paper's framing | medium | Each gate has a pre-specified "if not, then…" pivot. Don't defer; rewrite the affected section the same week. |
| AAAI deadline slips by your time | medium | Hard rule: if Week 11 (07-31) does not have a complete first draft, fail over to NAACL 2027 deadline (Oct). Don't try to "rush the last 2 weeks." |

## 8. Today's TODO

1. Read this plan end-to-end. Push back on anything that feels wrong
   *before* it's locked.
2. Confirm AAAI 2027 main is the target (vs NAACL backup).
3. Confirm subscription rate-limit headroom in your head: is running
   ~500 background agent rollouts over the next 7 weeks realistic for
   your usage pattern?
4. I'll then:
   - Write `paper/pre_registration.md` from the §4 template.
   - Write `experiments/judge_audit/sample.py` and `grade.py`.
   - Sketch `experiments/geometric_corpus/` skeleton.
   - Begin the AAAI LaTeX skeleton in `paper/aaai27/`.

Once those are in place, you start the geometric corpus and I trigger
Study 6 in the background.

---

*This plan is a living document.* Update it when a decision gate
fires. Do not silently let scope drift; either the plan changes or
the plan stays.
