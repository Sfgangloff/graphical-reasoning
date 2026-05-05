Experiment design: Lean-LSP-only vs. Lean-LSP + visualization tools
====================================================================

Goal
----
Compare Claude's performance on the formalized Putnam real-analysis
problems (putnam/real_analysis/) under two conditions:
  (A) lean-lsp-mcp tools only
  (B) lean-lsp-mcp + visualization tools (math-viz, math-compute, etc.)

Hypothesis: visualization tools help more on "graph-friendly" subtopics
(asymptotics, integral evaluation, region/area) than on others
(functional equations, polynomial identities, abstract existence).

----------------------------------------------------------------------
Metrics
----------------------------------------------------------------------

Primary
- Solve rate: fraction of `sorry`s discharged and theorems that
  compile cleanly. Compute mean over n >= 3 independent runs per
  (problem, condition); single-shot is too noisy.

Tool usage
- Per-tool call counts (lean_goal, lean_state_search, plot_function,
  draw_graph, sympy_eval, etc.), not just totals. Key question:
  when viz is available, does it crowd out lemma-search?
- Counterfactual viz use: fraction of *successful* proofs in the
  viz-enabled condition that actually invoked a viz tool. If viz
  is rarely used yet success rises, the effect is measuring prompt
  salience or tool diversity, not visualization per se.

Cost / efficiency
- Wall-clock time per attempt (with a fixed cap; see Setup).
- Token usage / API cost per problem (viz returns images = expensive
  context).
- Time-to-first-progress (first non-trivial tactic that survives)
  vs. time-to-completion. Viz may help orient before grinding.

Qualitative
- Claude's own end-of-attempt self-rating: which tool was decisive,
  on a short structured form. Useful as a sanity check on the
  quantitative tool-use distribution.

Graded fallback (recommended; see Tradeoff below)
- If raw solve rates are near 0, use a graded progress metric:
  percentage of goals discharged, or expert-rated 0/1/2/3 on a
  sampled subset of attempts. Otherwise a true difference can be
  hidden under "0% vs 0%."

----------------------------------------------------------------------
Setup
----------------------------------------------------------------------

Problem stratification
- Use the existing tags in real_analysis_problems.tex
  (integral-evaluation, limit-sequence, differentiability, ...).
- Pre-classify each problem as "graph-friendly" (asymptotics,
  integral evaluation, region/area, ODE phase plots) vs. "not"
  (functional equations, polynomial identities, abstract existence).
- The interaction (condition x category) is the real signal.

Budget / fairness
- Fixed budget per attempt: e.g. 30 min wall-clock OR N tool calls,
  whichever first. Without a cap, "time taken" is dominated by
  trivial cases and incomparable across conditions.
- Fresh context per problem (no carryover).
- Identical system prompt across conditions except for declared tool
  availability.

Repetition and analysis
- k = 3 to 5 runs per (problem, condition) pair to control for
  stochasticity.
- Within-problem paired analysis (e.g. Wilcoxon signed-rank on
  per-problem solve rates between A and B), not aggregate means
  alone. Pairing controls for problem difficulty.

Logging (per attempt)
- Suggested JSON schema:
    {
      "problem_id": "Y2003.B6",
      "condition": "A" | "B",
      "run_index": 0,
      "started_at": "...",
      "ended_at": "...",
      "wall_clock_s": ...,
      "outcome": "solved" | "partial" | "failed" | "timeout",
      "sorries_remaining": ...,
      "tool_calls": [
        {"tool": "lean_goal", "ts": "...", "args_summary": "..."},
        ...
      ],
      "tokens_in": ..., "tokens_out": ..., "cost_usd": ...,
      "self_report": {"decisive_tool": "...", "viz_useful": 0..3}
    }

----------------------------------------------------------------------
Main tradeoff to flag
----------------------------------------------------------------------

With `sorry`-stubs as the start state, the experiment nominally
measures proof completion, but most stubs likely won't be solvable
one-shot regardless of tools. Risk: actual measurement becomes
"did Claude make non-trivial progress" rather than "did it solve
it." Mitigations:
  1. Define a graded progress metric upfront (see Metrics).
  2. Pre-select ~20 problems judged most tractable and run deeper
     there, where solve-rate has signal.
Either is fine; commit before running so the analysis isn't
post-hoc.

----------------------------------------------------------------------
Open questions / next steps
----------------------------------------------------------------------

- Concrete harness: per-problem JSON log schema (above is a draft),
  prompt template, automated scoring script.
- Decision: full ~100 problems with graded scoring, or curated ~20
  with binary solve-rate?
- Decision: which exact viz/compute tools to enable in condition B
  (math-viz only, or also math-compute, math-search)? Each added
  tool changes what "viz" means.
