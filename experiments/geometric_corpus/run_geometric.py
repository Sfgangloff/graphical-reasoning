#!/usr/bin/env python3
"""Study 8 — geometric adversarial corpus rollout.

8 problems x 2 variants (true/false claim asserted) x 3 conditions
(forced_visual / forced_textual / forced_reflection) x k runs. For each
cell, ask the model to determine whether the asserted structural claim
is correct. Tests H8 (pre_registration.md): on the geometric corpus,
does forced_visual catch the false claim at a strictly higher rate than
forced_textual?

This runner deliberately REUSES the exact Study 5/6 treatment — the
prompt templates in `experiments/false_claim/prompts/` and the Claude
settings in `experiments/false_claim/settings/`. Keeping the three
conditions byte-identical to Study 6 means the ONLY thing that differs
between Study 6 and Study 8 is the corpus, so any forced_visual >
forced_textual gap here cannot be a prompt-wording artifact. The
machinery (cell skipping, poison-record auto-retry, self-report and
tool-call parsing, PNG read-back detection) is imported from
`run_false_claim.py` unchanged.

Pre-registered N: 8 problems x 2 x 3 x 5 runs = 240 cells.

Usage (from repo root):
    # cheap sanity check first — renders prompts, launches nothing:
    python3 experiments/geometric_corpus/run_geometric.py --dry-run
    # one-cell smoke test (spends tokens):
    python3 experiments/geometric_corpus/run_geometric.py \\
        --runs 1 --problems geom_01 --conditions forced_visual
    # full pre-registered run:
    python3 experiments/geometric_corpus/run_geometric.py --runs 5
"""
from __future__ import annotations

import argparse
import importlib.util
import time
from pathlib import Path

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[1]

# The 8 verified problems (geom_07 and geom_08 were dropped as too easy;
# see README.md "Problem types (build 8)"). Order matches canonical.json.
PROBLEMS = [
    "geom_01", "geom_02", "geom_03", "geom_04",
    "geom_05", "geom_06", "geom_09", "geom_10",
]
VARIANTS = ["true", "false"]
CONDITIONS = ["forced_visual", "forced_textual", "forced_reflection"]


def _load_false_claim_machinery():
    """Import run_false_claim.py as a module and re-point its corpus
    constants at the geometric corpus, while leaving its HERE (and thus
    its prompts/ + settings/ lookup) pointing at false_claim/ so the
    treatment stays shared. Importing is safe: run_false_claim guards
    its entry point behind `if __name__ == "__main__"`."""
    fc_path = REPO / "experiments" / "false_claim" / "run_false_claim.py"
    if not fc_path.exists():
        raise SystemExit(f"cannot find shared runner at {fc_path}")
    spec = importlib.util.spec_from_file_location("run_false_claim", fc_path)
    fc = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(fc)
    # Corpus-specific overrides. run_one() reads these module globals for
    # the excerpt source and the results destination; HERE (templates +
    # settings) is intentionally left as false_claim/.
    fc.EXCERPTS = HERE / "excerpts"
    fc.RESULTS = HERE / "results"
    return fc


def dry_run(fc, problems, variants, conditions, runs,
            budget_minutes, budget_calls) -> None:
    cells = [(p, v, c, r) for p in problems for v in variants
             for c in conditions for r in range(runs)]
    print(f"DRY RUN — {len(cells)} cells would launch "
          f"({len(problems)} probs x {len(variants)} variants x "
          f"{len(conditions)} conditions x {runs} runs).")
    # Validate every excerpt + template + settings file exists, and
    # render one full prompt so substitution can be eyeballed.
    missing = []
    for p in problems:
        for v in variants:
            ex = fc.EXCERPTS / f"{p}_{v}.tex"
            if not ex.exists():
                missing.append(str(ex))
    for c in conditions:
        tpl = fc.HERE / "prompts" / f"{c}.template.md"
        st = fc.HERE / "settings" / f"{c}.settings.json"
        if not tpl.exists():
            missing.append(str(tpl))
        if not st.exists():
            missing.append(str(st))
    if missing:
        print("  MISSING FILES:")
        for m in missing:
            print(f"    - {m}")
    else:
        print("  all excerpts + templates + settings present.")
    # Show a sample rendered prompt for the first cell.
    p0, v0, c0 = problems[0], variants[0], conditions[0]
    ex0 = fc.EXCERPTS / f"{p0}_{v0}.tex"
    tpl0 = fc.HERE / "prompts" / f"{c0}.template.md"
    if ex0.exists() and tpl0.exists():
        wrapup = max(1, budget_minutes - 1)
        prompt = fc.render(
            tpl0.read_text(),
            PROBLEM_ID=p0, VARIANT=v0, EXCERPT_PATH=ex0.name,
            BUDGET_MINUTES=str(budget_minutes),
            WRAPUP_MINUTES=str(wrapup),
            BUDGET_TOOL_CALLS=str(budget_calls),
        )
        print(f"\n--- sample rendered prompt ({p0}/{v0}/{c0}) ---")
        print(prompt)
        print("--- end sample prompt ---")


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--runs", type=int, default=5,
                    help="runs per cell (default 5 -> 240 cells)")
    ap.add_argument("--budget-minutes", type=int, default=12)
    ap.add_argument("--budget-calls", type=int, default=80)
    ap.add_argument("--problems", nargs="+", default=PROBLEMS,
                    choices=PROBLEMS)
    ap.add_argument("--variants", nargs="+", default=VARIANTS,
                    choices=VARIANTS)
    ap.add_argument("--conditions", nargs="+", default=CONDITIONS,
                    choices=CONDITIONS)
    ap.add_argument("--start-index", type=int, default=0)
    ap.add_argument("--dry-run", action="store_true",
                    help="list cells + render one prompt; launch nothing")
    args = ap.parse_args()

    fc = _load_false_claim_machinery()

    if args.dry_run:
        dry_run(fc, args.problems, args.variants, args.conditions,
                args.runs, args.budget_minutes, args.budget_calls)
        return

    cells = [(p, v, c, r) for p in args.problems
             for v in args.variants for c in args.conditions
             for r in range(args.start_index,
                            args.start_index + args.runs)]
    print(f"Study 8 — geometric adversarial corpus: {len(cells)} cells "
          f"({len(args.problems)} probs x {len(args.variants)} variants "
          f"x {len(args.conditions)} conditions x {args.runs} runs)  "
          f"budget={args.budget_minutes}min/cell")
    t0 = time.time()
    for i, (p, v, c, r) in enumerate(cells, 1):
        print(f"\n=== cell {i}/{len(cells)}  "
              f"{p} / {v} / {c} / r{r}  "
              f"(elapsed {(time.time()-t0)/60:.1f}min) ===")
        try:
            fc.run_one(p, v, c, r, args.budget_minutes, args.budget_calls)
        except Exception as e:
            print(f"  cell errored: {type(e).__name__}: {e}")
    print(f"\nDone in {(time.time()-t0)/60:.1f} min")


if __name__ == "__main__":
    main()
