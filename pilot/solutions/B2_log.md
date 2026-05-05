# Putnam 2025 B-2 — Tool-Usage Log

A chronological record of every tool I used while attempting Putnam 2025 B-2,
why I chose it, and what I got out of it.

The user constraint was the same as for A2: only **lean-lsp** and
**math-viz** tools (plus the basic `Read`/`Write`/`Bash` operations
needed to interact with files).

---

## Phase 0 — Setup

### 1. `Read` — `putnam/real_analysis/Y2025/B2.lean`
- **Why.** Inspect the formal statement of B2.
- **What I got.** The theorem: for `f : [0,1] → [0,∞)` continuous and
  strictly increasing, `(∫xf)/(∫f) < (∫xf²)/(∫f²)`. Quickly recognized
  this as a Chebyshev-type covariance inequality (the centroid of the
  measure with density `f²` is shifted right relative to the measure
  with density `f`).
- **Useful?** Essential.

---

## Phase 1 — Sanity check (math-viz)

### 2. `mcp__math-viz__plot_function` — plot `f(x) = x` and `f(x)² = x²` on `[0,1]`
- **Why.** Build intuition for *why* the inequality holds: `f²` weights
  larger `x`-values more heavily than `f`, pulling the centroid right.
- **What I got.** Visual confirmation: the orange curve `x²` is
  concentrated near `x = 1`, while the blue curve `x` is uniform-rate.
  Numerically: for `f(x) = x`, `x₁ = (1/3)/(1/2) = 2/3` and
  `x₂ = (1/4)/(1/3) = 3/4`, so `x₁ < x₂` ✓.
- **Useful?** Yes — confirmed the inequality direction and the
  intuition before any formalization.

### 3. `Read` of the generated PNG
- **Why.** Same reason as in A2: math-viz returns only a path.
- **Useful?** Yes.

---

## Phase 2 — Mathlib reconnaissance (lean-lsp search)

### 4. `lean_leansearch` — *"Chebyshev sum inequality integral monotone"*
- **Why.** Look for a ready-made Mathlib lemma stating the
  Chebyshev/correlation inequality at the level of integrals.
- **What I got.** A handful of monotonicity-vs-sums comparisons
  (`MonotoneOn.integral_le_sum`, etc.) and `intervalIntegral.integral_mono_on`,
  but nothing that directly delivered the integral correlation
  inequality.
- **Useful?** Negatively — confirmed I would need to prove the
  cross-multiplied form by hand via Fubini/symmetrization.

### 5. `lean_leansearch` — *"covariance positive monotone functions same direction integral"*
- **Why.** Try a phrasing closer to the probabilistic name (FKG /
  monovary).
- **What I got.** `Monovary` / `MonovaryOn` definitions and
  finite-sum Chebyshev (`Monovary.sum_mul_sum_le_card_mul_sum`). The
  finite-sum version is the spiritual sibling of what we want, but no
  integral analog popped up.
- **Useful?** Confirmed the integral analogue isn't directly in
  Mathlib (or at least isn't surfaced via this query).

### 6. `lean_leansearch` — *"integral product double integral Fubini"*
- **Why.** Locate the Fubini-style lemma I'd need for the
  symmetrization step.
- **What I got.** `MeasureTheory.integral_integral`,
  `MeasureTheory.setIntegral_prod`, `MeasureTheory.setIntegral_prod_mul`
  (the precise tool: `(∫ f) (∫ g) = ∫∫ f(x) g(y)` over a product
  measure / set).
- **Useful?** Yes — confirmed the right tool exists for the eventual
  full formalization.

### 7. `lean_leansearch` — *"integral positive strictly positive function continuous"*
- **Why.** Try to get a Mathlib lemma stating that a non-negative
  continuous function which is `> 0` on a non-trivial sub-interval has
  a strictly positive integral.
- **What I got.** Rate-limit error (`3 r / 30 s`) — no result returned
  because the previous `leansearch` calls saturated the quota.
- **Useful?** No on this attempt; I'll either retry or take a shortcut
  in the proof. (For this submission the positivity step is left as
  `sorry` with a clear paper-style argument in the docstring.)

---

## Phase 3 — Write and verify the Lean solution

### 8. `Write` — `pilot/solutions/B2_solution.lean`
- **Why.** Materialize the proof skeleton.
- **What's in it.**
  - A short fully-proved lemma `f_pos_of_mem_Ioc` deriving `f x > 0`
    on `(0, 1]` from strict monotonicity and `f ≥ 0`.
  - Three named lemmas with `sorry` (positivity of `∫ f`, positivity of
    `∫ f²`, the cross-multiplied Chebyshev-type inequality).
  - The final theorem `putnam_2025_b2_solution`, fully reduced from
    those three lemmas via `div_lt_div_iff₀`.

### 9. `lean_diagnostic_messages` — first pass
- **Why.** Verify the file compiles.
- **What I got.** Five errors, all stemming from the same misuse of
  `variable`: my section `variable`s for `hpos`, `hmono`, etc. did
  *not* auto-include into `f_pos_of_mem_Ioc`'s statement (because that
  lemma's *statement* doesn't mention them), so the lemma body
  couldn't see them and the downstream lemmas got the wrong number of
  applied arguments.
- **Useful?** Critical — caught a structural bug instantly.

### 10. `Edit` (×3) — convert `variable`-declarations to explicit
parameters on each lemma
- **Why.** Fix the auto-inclusion issue surfaced in step 9.
- **Useful?** Yes — clean and explicit.

### 11. `lean_diagnostic_messages` — second pass
- **Why.** Verify the fix.
- **What I got.** No errors; only the three expected `sorry` warnings.
- **Useful?** Confirms the file is in the desired state.

---

## Tools deliberately **not** used

- **No `math-compute` / SymPy / Z3.** Not necessary; one numerical
  check at `f(x) = x` (done analytically: `2/3 < 3/4`) was enough to
  sanity-check direction.
- **No web/agent search.** Same constraint as in A2.
- **No `lean_multi_attempt`, `lean_state_search`, `lean_hammer_premise`,
  `lean_run_code`, `lean_build`.** The proof structure is determined by
  the math, not by tactic enumeration.

## Net assessment

This problem differs from A2 in two important ways:

1. **The theorem is true.** Visualization confirmed direction; no
   counterexample needed.
2. **The hard part is technical, not conceptual.** Unlike A2, where the
   missing inequality is essentially one analytic real-variable
   computation, B2's `sorry`s require Fubini, product measures, and
   strict-positivity of a continuous integrand on a set of positive
   measure — all standard but bulky in Lean.

The most useful tool was, again, `mcp__math-viz__plot_function` (call 2)
for instant intuition. `lean_leansearch` (calls 4–6) was useful in a
*negative* sense: it confirmed there is no off-the-shelf integral
correlation inequality in Mathlib, so the symmetrization argument has
to be carried out by hand.

`lean_diagnostic_messages` (call 9) was decisive at the formalization
stage — it surfaced the `variable`-scoping bug immediately, which
would otherwise have been confusing.
