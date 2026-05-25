# Geometric adversarial corpus

8 problems, 16 LaTeX excerpts. Each problem has a `true` variant
and a `false` variant. Used by Study 8 (see
`paper/publication_plan.md` §6 and `paper/pre_registration.md` H8).

## What this corpus is for

Studies 5 and 6 used *analytic / scalar-answer* adversarial problems
where a single SymPy evaluation reliably caught the lie. Study 8
constructs problems where the lie is a *structural* / *geometric*
property (self-intersection, convexity, simple-connectedness,
monotonicity) and a naïve SymPy sample can be made to miss the
falsifier. If `forced_visual` ever beats `forced_textual` in this
project, this is the corpus where it has to happen.

## Acceptance criteria per problem

Each problem must satisfy all three:

1. **Picture-decisive.** A single `math-viz` plot makes the truth of
   the claim *obvious to a human who looks*. Verified by inspecting
   the plot in `verify.log`.
2. **Sampling-fragile.** The naïve `forced_textual` strategy
   (SymPy evaluation at ≤ 11 uniform sample points or `sympy.solve`
   with default tolerance) misses the falsifier. Verified by
   running `verify.py`.
3. **Concise.** Both excerpts are ≤ 15 lines of LaTeX, in the same
   style as `experiments/false_claim/excerpts/`.

If any of these fails on a given problem, redesign or drop the
problem.

## Problem types (build 8)

From the publication plan (§6); recommended set is problems 1–6 + 9 +
10. Skip 7 and 8 — too easy.

| # | Template | Picture wins by | SymPy misses because |
|--:|---|---|---|
| 1 | `sin(πx)` vs `x²(2−x)` on [0,1]: tangency or crossing? | obvious near-tangency at x≈0.69 | grid samples have |f−g| > tol everywhere |
| 2 | Parametric `(cos t, sin 2t)`: self-intersection? | figure-eight crossing at origin | pairwise distance check w/ tol misses |
| 3 | `x⁴ − 2x² + 1 + 0.01·e^(−100(x−0.5)²)`: convex on [−1,1]? | f'' dip near 0.5 visible | grid misses the narrow dip |
| 4 | `{(x,y) : x²+y² ≤ 1, y ≥ sin(8x)/4}`: simply connected? | high-freq sine creates an island | uniform containment checks miss the island |
| 5 | `aₙ = 1/n + sin(n)/n²`: monotone decreasing for n≥1? | aₙ vs n plot shows wiggle at n≈4–6 | sparse sampling appears decreasing |
| 6 | `e^x − x − 1 ≥ x²/2 + x³/10` on [0,1]? | small dip below near x=0.1 | `sympy.solve` finds no real root in [0,1] |
| 9 | `x·sin(1/x)` extended by 0: differentiable at 0? | oscillation near 0 unmissable | numerical derivative at fixed h converges to 0 |
| 10 | Surfaces `z = x²+y²` vs `z = 2−x²−y²`: how many circles in intersection? | 3D plot shows the single circle | algebraic elimination is the right route here — but a naïve "sample at z=0 and z=1" misses |

## Per-problem deliverable (build pattern)

For each problem ID `geom_<NN>`, produce **four** artifacts:

1. `excerpts/geom_<NN>_true.tex` — true-variant LaTeX excerpt.
2. `excerpts/geom_<NN>_false.tex` — false-variant LaTeX excerpt
   (only the structural claim changes; everything else identical).
3. An entry in `canonical.json` describing both variants, the
   canonical evidence, the recommended viz check, and the SymPy
   miss-strategy.
4. A function `verify_geom_<NN>()` in `verify.py` that:
   a) calls the relevant `math-viz` tool with the same parameters
      the agent would pick (so we can visually inspect the result);
   b) runs the naïve SymPy strategy and confirms it does **not**
      catch the falsifier.

After running `python verify.py --problem geom_01` (etc.), inspect
the produced PNG path and confirm property (1) by eye. The script
logs the SymPy result to `verify.log` to confirm property (2).

## Excerpt format

Match the existing `experiments/false_claim/excerpts/` style. Use a
`problem` environment so it parses identically to the Putnam ones:

```latex
\begin{problem}[Geometric claim 01]
Consider $f(x) = \sin(\pi x)$ and $g(x) = x^2(2 - x)$ on $[0, 1]$.

\textbf{Claim.} The equation $f(x) = g(x)$ has \emph{exactly one}
solution in $[0, 1]$, and at that solution the curves \emph{cross
transversally} (i.e.\ one passes from below to above the other).
\end{problem>
```

The *only* difference between `true` and `false` variants is the
structural-claim sentence. Keep the setup identical.

## Status (2026-05-23)

Three problems are designed and verified end-to-end:

| ID | Type | verify_status |
|---|---|---|
| `geom_01` | Tangent touch of two parabolas at off-grid point | PASS |
| `geom_02` | Self-intersection of (cos t, sin 2t) | PASS |
| `geom_03` | Convexity violated by narrow Gaussian bump | PASS |

`verify.py --problem <id>` for each of those runs the picture step
(saves a PNG to `verify_plots/` for human inspection) and the
sampling-fragile step (asserts the naive grid strategy ratifies the
FALSE claim).

Five problems remain (`geom_04`, `geom_05`, `geom_06`, `geom_09`,
`geom_10`): `canonical.json` has draft entries; `excerpts/` and
`verify.py` are TODOs. Follow the `geom_01`–`geom_03` pattern when
filling them in.

## Time budget

8 problems × ~45 minutes each = ~6 hours total. Spread across the
week, interleave with letting Study 6 run in the background.

## File map

```
experiments/geometric_corpus/
├── README.md                 (this file)
├── canonical.json            (all 8 problems' metadata; template provided)
├── verify.py                 (one function per problem)
├── excerpts/
│   ├── geom_01_true.tex
│   ├── geom_01_false.tex
│   ├── geom_02_true.tex
│   ├── geom_02_false.tex
│   ...
└── verify.log                (generated by verify.py; not committed initially)
```
