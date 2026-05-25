# Pre-registration: Studies 6, 7, 8 + judge audit

**Authored:** 2026-05-21.
**Repo state at authoring:** commit `9e5fd98` on branch `main`.
**Submitter:** Silvere Gangloff.
**Target venue:** AAAI 2027 main track.
**Authoritative working document:** `paper/publication_plan.md`.

**Posted to OSF on:** _(fill in OSF URL + timestamp after upload)_

---

## 1. Purpose of this document

This document fixes the hypotheses, primary outcomes, statistical
tests, decision rules, and stopping rules for **three new studies
(Studies 6, 7, 8) and the human judge audit (HJ)** *before any data
for those studies is collected*. It exists to defeat post-hoc-framing
concerns at peer review.

It does **not** retroactively pre-register Studies 1–5. Those are
exploratory by definition and the paper will say so. The replication
of Study 5 at higher n (re-named *Study 6* below) is pre-registered
here.

## 2. Transparency: what is and isn't pre-registered

| Study | Pre-registered? | Status as of 2026-05-21 |
|---|---|---|
| 1 — A/B sweep (120 attempts) | No (exploratory) | Complete, committed in main |
| 2 — Input-framing probe (27) | No (exploratory) | Complete, committed |
| 3 — Forced-loop ablation (54) | No (exploratory) | Complete, committed |
| 4 — Recall probes 4a, 4a' (36) | No (exploratory) | Complete, committed |
| 5 — Adversarial pilot (48) | No (exploratory) | Complete, committed |
| **6 — Scaled adversarial (96 new)** | **Yes (this doc)** | Not yet run |
| **7 — Path-only regression on inline `math-viz` (144)** | **Yes (this doc)** | Not yet run |
| **8 — Geometric adversarial corpus (240)** | **Yes (this doc)** | Not yet run |
| **HJ — Human judge audit (120 cells)** | **Yes (this doc)** | Not yet run |

## 3. Hypotheses, tests, and decision rules

### H6 — Modality equivalence on the original adversarial corpus

**Hypothesis (declarative):** On the 4-problem false-claim corpus, at
combined sample size n = 8 (existing Study 5) + 16 (new Study 6) = 24
runs per condition, the three forced-verification conditions
(`forced_visual`, `forced_textual`, `forced_reflection`) have
indistinguishable false-claim catch rates.

**Primary outcome:** count of `false`-variant runs graded `CORRECT`
by the LLM judge (verdict = `incorrect` *and* canonical-answer
regex match), per (condition × problem), summed across problems.

**Test:** Fisher's exact on the 3 × 2 contingency
(condition × {caught, not caught}) over all `false`-variant cells.
Pairwise Fisher's exact (3 pairs) with Bonferroni correction
(α effective = 0.05/3 = 0.0167).

**Decision rule:**
- *Modality-doesn't-matter supported* iff no pairwise comparison
  reaches p < 0.0167 *and* the overall 3 × 2 Fisher's exact yields
  p > 0.05.
- *Modality matters* iff any pairwise comparison reaches
  p < 0.0167.

**No-peeking commitment:** Study 6's 96 new cells are run before any
hypothesis test is computed. The cell-by-cell grades are computed
only after all 96 runs are recorded.

### Study 7 design note (revised 2026-05-23)

The original Study 7 design proposed *adding* an inline-content
mode to a path-returning `math-viz`. That design is moot: upstream
`math-viz` already returns inline image content as of commit
`1622bac` on 2026-05-07, and Studies 2–5 in the long-form paper all
ran post-switch. Study 7 is therefore reframed as a **path-only
regression**. We build a thin wrapper around the current `math-viz`
that strips the inline image content block from each tool result,
leaving only the filesystem path as text. The baseline arm is the
unmodified upstream tool (inline image returned); the manipulated
arm is the wrapped tool (path-only). Hypothesis direction and
sample size are unchanged from the pre-revision draft.

### H7a — Inline-image return lifts voluntary adoption

**Hypothesis:** In the `optional × inline` arm of Study 7,
voluntary `math-viz` adoption (fraction of cells with ≥1 successful
`math-viz` invocation) is ≥ 15 absolute percentage points higher
than in the `optional × path-only` arm.

**Primary outcome:** binary adoption per cell.

**Test:** Paired binomial across the 6 problems
(`optional × inline` vs `optional × path-only` adoption rates per
problem). Test statistic: one-sided sign test on the per-problem
difference; α = 0.05.

**Decision rule:**
- *H7a supported* iff the one-sided sign test reaches p < 0.05
  *and* the mean per-problem lift is ≥ 15 absolute points.

### H7b — Inline-image return shifts grounding from metadata to image

**Hypothesis:** Conditional on adoption, agents in the inline arm
reference image features (e.g., shape, curve crossing, slope
visible, region position) in ≥ 50% of emitted verdicts; agents in
the path-only arm reference image features in ≤ 20% of emitted
verdicts.

**Caveat from prior data.** §9.2 of the long-form paper (Studies
2–5, post-switch, `forced_visual` arm) finds that even with inline
images delivered automatically, the agent grounds verdicts in the
plotting tool's *numerical metadata* rather than in image features.
Those cells were *forced* uses; Study 7 measures *voluntary* uses,
where the prior probability of image grounding may differ. We
pre-register the directional hypothesis but report both
possibilities — *inline lifts grounding* (H7b supported) and
*neither arm grounds in images* (H7b refuted in an informative
direction) — as primary findings of the study.

**Primary outcome:** binary "image-feature reference" per verdict,
hand-coded by the author on 20 random adopted cells per arm (40
total) using the fixed coding rubric below, committed before any
hand-coding begins.

**Test:** Fisher's exact on the 2 × 2 (arm × {image-feature, no})
table; α = 0.05.

**Decision rule:**
- *H7b supported* iff Fisher's exact p < 0.05 *and* the empirical
  proportions match the directional hypothesis.
- *H7b refuted (informative null)* iff both arms have ≤ 25%
  image-feature reference rate. This is the §9.2-consistent
  outcome and is reported as such.

**Coding rubric (committed before coding):**
- An "image-feature reference" requires the verdict text to invoke
  a *visual* property (shape, curvature visible, region containment
  read off the plot, crossing point identified by eye) that could
  not be obtained from numerical sample values alone.
- A "metadata-only reference" cites numbers (e.g., "f(1) = 0.24"),
  symbolic results, or tool textual return without invoking a
  visual property.
- Ambiguous: flagged separately; counted as "no image-feature
  reference" for the primary test, audited in the appendix.

### H8 — Picture beats numerics on the geometric adversarial corpus

**Hypothesis:** On the 8-problem geometric adversarial corpus,
`forced_visual` catches false claims at a strictly higher rate than
`forced_textual` (one-sided).

**Primary outcome:** per-problem false-claim catch rate.

**Test:** Paired one-sided binomial across the 8 problems
(per-problem catch rate, `forced_visual` − `forced_textual`).
Test statistic: sign test on per-problem differences; α = 0.05.
Secondary: paired comparison `forced_visual` vs `forced_reflection`
(two-sided, α = 0.05).

**Decision rule:**
- *H8 supported* iff one-sided sign test p < 0.05 in the
  `forced_visual` > `forced_textual` direction *and* the mean
  per-problem advantage is ≥ 10 absolute points.
- *Null result* otherwise. A null result is itself a publishable
  finding — see decision-gate 3 in `publication_plan.md`.

### HJ — Human judge audit calibration

**Hypothesis:** Cohen's κ between human grades and LLM judge grades
on the 120-cell stratified random sample is ≥ 0.6 overall and ≥ 0.5
per study stratum.

**Primary outcome:** κ statistic, computed over the binary
{CORRECT, not-CORRECT} judgment (treating UNCLEAR as not-CORRECT for
the primary test; sensitivity analysis treating UNCLEAR as
abstention reported in appendix).

**Decision rule:**
- κ ≥ 0.6 overall *and* ≥ 0.5 per stratum → LLM judge accepted, no
  re-grading needed; paper reports κ.
- κ < 0.5 on any stratum → that stratum's grades switched to
  3-judge majority vote (LLM-judge plus 2 different-prompted LLM
  re-runs) and the affected analyses are re-run with the new grades.
- Disagreement cells listed in appendix with one-line explanation,
  regardless of κ value.

## 4. Sample sizes and power

| Study | Cells | n per condition | Power note |
|---|---:|---:|---|
| 6 | 96 new + 48 existing = 144 | 24 per condition (false only) | At π₁ = 0.875, π₂ = 0.625, n = 24 each, Fisher's exact has ~50% power at α = 0.0167. We pre-accept that *failure to reject* is *not* equivalence; we will report effect-size confidence intervals alongside p-values. |
| 7 | 144 | 36 per arm | Detects a 15-pt lift at ~85% power (binomial, α = 0.05). |
| 8 | 240 | 40 per condition (across 8 problems, 5 runs each) | Detects a 15-pt per-problem advantage at ~80% power. |
| HJ | 120 | 20–30 per stratum | κ = 0.6 detectable against null κ = 0.4 at ~80% power. |

## 5. Stopping rules

- **No early stopping** for any study. Each study is run to its
  pre-registered N before any per-condition statistics are computed
  beyond raw catch counts.
- **No N inflation** after the fact. If a study's effect appears
  marginal, the result is reported as marginal, not topped up.
- **One pre-registered re-grading round** allowed for the human
  judge audit only, triggered by κ < 0.5 on any stratum, and limited
  to 3-judge LLM majority vote on the affected cells.

## 6. Files this pre-registration governs

- Driver scripts:
  - Study 6: `experiments/false_claim/run_false_claim.py`
    (re-invoked with `--n-additional 4`)
  - Study 7: `experiments/inline_content/run_inline_content.py`
    (to be created) plus
    `experiments/inline_content/path_only_wrapper.py` — the thin
    wrapper that strips inline image content blocks from each
    `math-viz` tool result before the agent sees it. The baseline
    arm calls upstream `math-viz` directly; the manipulated arm
    routes through the wrapper.
  - Study 8: `experiments/geometric_corpus/run_geometric.py`
    (to be created)
- Corpora:
  - Study 8: `experiments/geometric_corpus/excerpts/`,
    `experiments/geometric_corpus/canonical.json`
- Judge audit:
  - Sampling: `experiments/judge_audit/sample.py`
  - Grading CLI: `experiments/judge_audit/grade.py`
  - Output: `experiments/judge_audit/sample.csv`,
    `experiments/judge_audit/grades.csv`
- Coding rubric for H7b: `experiments/inline_content/coding_rubric.md`
  (committed before any hand-coding).

## 7. OSF upload checklist

- [ ] Render this file to PDF.
- [ ] Upload PDF to a new OSF project titled
      "graphical-reasoning: AAAI 2027 pre-registration".
- [ ] Capture the OSF URL and the timestamp.
- [ ] Update the "Posted to OSF on" line at the top of this file.
- [ ] Commit the updated line. The OSF timestamp + the git commit
      timestamp together form the defensible evidence trail.
- [ ] Do this *before* any new agent run for Studies 6/7/8.
