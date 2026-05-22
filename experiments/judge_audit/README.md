# Human judge audit

Tooling for the 120-cell human-vs-LLM-judge calibration described in
`paper/publication_plan.md` §5 and pre-registered in
`paper/pre_registration.md` §HJ.

## What this is

The LLM judge that grades agent verdicts shares failure modes with
the agent under test. To defend against the "single LLM judge"
attack at AAAI review, we hand-grade a stratified random sample of
120 cells and report Cohen's κ between human and LLM-judge labels.

## Workflow

1. **Sample.** Run `python sample.py --study <name> --n <k>` once
   per study. Output goes to `samples/<study>.csv`.
2. **Grade.** Run `python grade.py samples/<study>.csv`. Interactive
   CLI that walks one cell at a time. Resumable.
3. **Aggregate.** Run `python kappa.py samples/*.csv`. Prints
   per-study and overall Cohen's κ + agreement %.

## Sample plan (target: 120 total)

| Study | Sample size | Source dir |
|---|---:|---|
| `study3` (forced viz) | 25 | `experiments/forced_viz/results/` |
| `study5` (false claim pilot) | 20 | `experiments/false_claim/results/` (existing n=2/cell) |
| `study6` (scaled adversarial) | 30 | `experiments/false_claim/results/` (new n=6/cell rows) |
| `study7` (inline content) | 25 | `experiments/inline_content/results/` |
| `study8` (geometric) | 20 | `experiments/geometric_corpus/results/` |

All sampling uses seed 42 + study-name salt. Reproducible.

## Grading rubric

Per cell, you assign one of:

- **`c` (CORRECT)** — agent's verdict matches ground truth; on `false`
  variants, the stated corrected answer is mathematically equivalent
  to the canonical answer (modulo formatting/whitespace).
- **`w` (WRONG)** — agent's verdict contradicts ground truth, OR (on
  `false` variants) corrected answer is mathematically wrong.
- **`u` (UNCLEAR)** — output malformed, missing, or genuinely
  ambiguous. The grader cannot decide either way.

You see four fields per cell:
1. The LaTeX excerpt the agent saw.
2. The canonical ground-truth answer.
3. The agent's emitted `verdict` and `correct_answer`.
4. (Hidden until after your grade) The LLM judge's label.

**Do not peek at field 4 before grading.** The CLI hides it.

## Calibration block

Before starting your 120-cell run, do the 10-cell calibration block:
`python grade.py samples/calibration.csv`. This is a pre-marked
sample where I (the assistant) have also graded each cell. After you
finish, run `python kappa.py samples/calibration.csv --vs-me` to see
our agreement. If κ < 0.7 on the calibration, talk through
disagreements before continuing.

## Time budget

- 120 cells / ~4 minutes each ≈ 8 hours total.
- Recommended: 4 sessions × 2 hours, spread over 3 days. Fatigue
  degrades reliability.

## Acceptance criteria

- 120 cells graded (plus 10 calibration).
- Overall κ ≥ 0.6.
- Per-study κ ≥ 0.5.
- All disagreements have one-line notes (CLI prompts for them).
- Raw grades committed to `samples/<study>.csv`.
