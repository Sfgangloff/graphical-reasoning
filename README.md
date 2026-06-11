# graphical-reasoning

Experiment code for a study of whether **visualization / plotting tools** (the
`math-viz` MCP server) help an LLM coding agent (Claude Code) solve **Putnam**
real-analysis problems formalized in Lean 4 — an A/B sweep plus a chain of
adoption and modality ablations.

> **The research reasoning lives elsewhere.** Questions, hypotheses, findings,
> and how the project's thinking evolved are maintained as a structured
> reasoning graph in the **research-compiler** database, stream
> **`visualization-tools-putnam`**. This repository keeps only the experiment
> apparatus, corpora, and results. To read the reasoning, open the
> research-compiler web app or run
> `rc export paper --stream visualization-tools-putnam`. Each study below is the
> node `e-00NN` in that stream.

## Headline

The central finding is **discovery dominates value**: in unattended / optional
mode the agent invokes `math-viz` essentially never, so end-task A/B contrasts
measure *adoption*, not *value*. Forcing the loop delivers the tool but does not
change solving on a corpus where prose chain-of-thought already saturates; and
when verification is forced on adversarial claims, the corrective work is the
*required pause*, not the *modality* (visual ≈ textual ≈ reflection). See the
stream for the full reasoning chain and caveats.

## Experiment index

Each row is a node in the `visualization-tools-putnam` stream. Raw per-run data
lives under each study's `results/`.

| Node | Study | What it tests | How to run |
| --- | --- | --- | --- |
| `e-0001` | S1 — main A/B sweep (viz vs no-viz), 120 runs | does +math-viz solve more? | `python -m experiments.runner.run_matrix` |
| `e-0002` | S2 — input-framing probe, 27 runs | does Lean-stub framing pull in tools? | `python -m experiments.probe_framing.run_probe` |
| `e-0003` | S3 — forced-viz loop, 54 runs | information vs requirement; does forcing help? | `python -m experiments.forced_viz.run_forced` |
| `e-0004` | S4a/4a′ — recall vs CoT, 36 runs | headroom / reasoning-depth control | `python -m experiments.recall_test.run_recall_cot` |
| `e-0005` | S5 — adversarial false-claim × 3 modalities, 48 cells | visual vs textual vs reflection | `python -m experiments.false_claim.run_false_claim` |
| `e-0006` | S6 — false-claim scaled to n=24, 144 cells | modality equivalence at scale | `python -m experiments.false_claim.run_false_claim` |
| `e-0007` | S7 — inline vs path-only adoption, 144 cells | does inline image return lift adoption? | `python -m experiments.inline_content.run_inline_content` |
| `e-0008` | S8 — geometric picture-decisive corpus (*planned*) | does forced-visual finally beat textual? | `python -m experiments.geometric_corpus.run_geometric` (corpus: `verify.py --all`) |
| `e-0009` | judge audit — human ↔ LLM κ | judge reliability | `python -m experiments.judge_audit.kappa` |

## Layout

```
experiments/   rollout harness (runner/) + one dir per study (run_*.py, analyze_*.py,
               prompts/, settings/, results/), problem_excerpts/, workspace_template/
putnam/        statement-level Lean 4 / Mathlib formalizations of Putnam
               real-analysis problems (1985–2025) — the substrate
pilot/         manual interactive sessions used as the positive control (2025 A-2, B-2)
external/math-reasoning-tools/   git submodule: the MCP tool servers under test
                                 (math-viz, math-compute, …) — do not edit directly
Putnam.lean, lakefile.toml, lean-toolchain   Lean build
```

## The tools under test

`math-viz` (plots, regions, phase portraits, LaTeX rendering) is the treatment;
the related `math-compute` (SymPy / Z3) supplies the textual/numeric verification
arm in the modality ablations. Both come from the pinned submodule:

> `external/math-reasoning-tools/` → [Sfgangloff/math-reasoning-tools](https://github.com/Sfgangloff/math-reasoning-tools)

```
git submodule update --init --recursive
```

## Building the Lean substrate

```bash
lake exe cache get   # fetch precompiled Mathlib oleans (otherwise the first build is very slow)
lake build           # type-checks every formalized problem
```
