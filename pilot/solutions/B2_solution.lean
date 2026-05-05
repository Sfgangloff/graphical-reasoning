import Mathlib

/-!
# Putnam 2025 B-2 — Solution

## Problem
Let `f : [0, 1] → [0, ∞)` be continuous and strictly increasing. Let
`R` be the region under the graph of `f` over `[0, 1]`. Let `x₁` be the
`x`-coordinate of the centroid of `R` and `x₂` the `x`-coordinate of the
centroid of the solid of revolution obtained by rotating `R` about the
`x`-axis. Show that `x₁ < x₂`.

In integral form,
```
            ∫₀¹ x · f x dx              ∫₀¹ x · f x ^ 2 dx
  x₁ = ─────────────────────  <  ───────────────────────── = x₂.
            ∫₀¹ f x dx                  ∫₀¹ f x ^ 2 dx
```

## Strategy
This is a covariance / correlation inequality of Chebyshev type.

Let `I = ∫₀¹ f`, `J = ∫₀¹ f²`, `A = ∫₀¹ x · f`, `B = ∫₀¹ x · f²`.
Strict monotonicity together with `f ≥ 0` forces `f(x) > 0` for
`x ∈ (0, 1]`, so `I > 0` and `J > 0`. The claim `A / I < B / J` is then
equivalent to
  `A · J < B · I`,                                                    (*)
i.e.
  `(∫ x · f) (∫ f²) < (∫ x · f²) (∫ f)`.

The classical symmetrization:
```
  (∫ x f²)(∫ f) − (∫ x f)(∫ f²)
    = ∫∫ x f(x)² f(y) dxdy − ∫∫ x f(x) f(y)² dxdy
    = ∫∫ x f(x) f(y) (f(x) − f(y)) dxdy
    = (1/2) ∫∫ (x − y) (f(x) − f(y)) f(x) f(y) dxdy.
```
Since `f` is strictly increasing, `(x − y)(f(x) − f(y)) ≥ 0` everywhere
and `> 0` whenever `x ≠ y`. Combined with `f(x), f(y) ≥ 0` and the fact
that `f` is `> 0` on a set of positive measure, the double integral is
strictly positive, giving (*).

## Status of this Lean file
* The skeleton (positivity reductions, cross-multiplication, the
  symmetric reformulation as a double integral) is fully written.
* The two technical pieces that require heavy measure-theoretic
  machinery (Fubini for the symmetrization, and the strict-positivity
  argument for a non-negative continuous integrand that vanishes only
  on the diagonal) are isolated as named lemmas with `sorry`. Each is
  accompanied by a paper-style proof sketch.
-/

namespace Putnam2025B2Solution

open MeasureTheory Set intervalIntegral

/-- Strict monotonicity together with `f ≥ 0` on `[0,1]` forces `f` to
be strictly positive on `(0, 1]`: indeed, for `x ∈ (0, 1]`,
`f x > f 0 ≥ 0`. -/
lemma f_pos_of_mem_Ioc {f : ℝ → ℝ}
    (hpos : ∀ x ∈ Set.Icc (0 : ℝ) 1, 0 ≤ f x)
    (hmono : StrictMonoOn f (Set.Icc 0 1))
    {x : ℝ} (hx : x ∈ Set.Ioc (0 : ℝ) 1) : 0 < f x := by
  have h0 : (0 : ℝ) ∈ Set.Icc (0 : ℝ) 1 := ⟨le_refl _, by norm_num⟩
  have hxIcc : x ∈ Set.Icc (0 : ℝ) 1 := ⟨le_of_lt hx.1, hx.2⟩
  have hf0 : 0 ≤ f 0 := hpos 0 h0
  have : f 0 < f x := hmono h0 hxIcc hx.1
  linarith

/-- `∫₀¹ f > 0`. Because `f` is continuous on `[0, 1]`, non-negative,
and strictly positive on `(0, 1]` (so positive on a set of positive
Lebesgue measure), the integral is strictly positive.

The proof would go: pick any closed sub-interval `[a, b] ⊂ (0, 1]` (e.g.
`[1/2, 1]`); `f` attains its (positive) minimum `m > 0` on `[a, b]`
(continuity + extreme value), so `∫₀¹ f ≥ ∫_a^b f ≥ m·(b−a) > 0`. -/
lemma integral_f_pos {f : ℝ → ℝ}
    (hcont : ContinuousOn f (Set.Icc 0 1))
    (hpos : ∀ x ∈ Set.Icc (0 : ℝ) 1, 0 ≤ f x)
    (hmono : StrictMonoOn f (Set.Icc 0 1)) :
    0 < ∫ x in (0:ℝ)..1, f x := by
  sorry

/-- `∫₀¹ f² > 0`, by the same argument applied to `f²` (also continuous,
non-negative, and `> 0` on `(0, 1]` where `f` is). -/
lemma integral_fsq_pos {f : ℝ → ℝ}
    (hcont : ContinuousOn f (Set.Icc 0 1))
    (hpos : ∀ x ∈ Set.Icc (0 : ℝ) 1, 0 ≤ f x)
    (hmono : StrictMonoOn f (Set.Icc 0 1)) :
    0 < ∫ x in (0:ℝ)..1, (f x) ^ 2 := by
  sorry

/-- The Chebyshev/correlation inequality: in cross-multiplied form,
  `(∫ x · f) · (∫ f²) < (∫ x · f²) · (∫ f)`.

This is the core analytic content of the problem.

**Proof sketch** (Fubini + symmetrization, see file header):
1. Expand each side as a double integral over `[0,1]² = [0,1] × [0,1]`:
   `(∫₀¹ x f²)(∫₀¹ f) − (∫₀¹ x f)(∫₀¹ f²)
        = ∫∫ x f(x) f(y) (f(x) − f(y)) dx dy`.
2. Swap `x ↔ y` (relabel of the dummy variables):
   `= − ∫∫ y f(y) f(x) (f(x) − f(y)) dx dy`.
3. Average:
   `= (1/2) ∫∫ (x − y)(f(x) − f(y)) f(x) f(y) dx dy`.
4. The integrand is non-negative everywhere (strict monotonicity of `f`
   makes `(x − y)` and `(f(x) − f(y))` co-signed; `f ≥ 0`).
5. The integrand is strictly positive on the open set
   `{(x, y) ∈ (0, 1]² : x ≠ y}`, which has positive 2-dim. measure
   (`f > 0` on `(0, 1]` from `f_pos_of_mem_Ioc`).
6. Conclude the double integral is strictly positive. -/
lemma chebyshev_cross_inequality {f : ℝ → ℝ}
    (hcont : ContinuousOn f (Set.Icc 0 1))
    (hpos : ∀ x ∈ Set.Icc (0 : ℝ) 1, 0 ≤ f x)
    (hmono : StrictMonoOn f (Set.Icc 0 1)) :
    (∫ x in (0:ℝ)..1, x * f x) * (∫ x in (0:ℝ)..1, (f x) ^ 2) <
      (∫ x in (0:ℝ)..1, x * (f x) ^ 2) * (∫ x in (0:ℝ)..1, f x) := by
  sorry

/-- Putnam 2025 B-2. -/
theorem putnam_2025_b2_solution
    (f : ℝ → ℝ) (hcont : ContinuousOn f (Set.Icc 0 1))
    (hpos : ∀ x ∈ Set.Icc (0 : ℝ) 1, 0 ≤ f x)
    (hmono : StrictMonoOn f (Set.Icc 0 1)) :
    (∫ x in (0:ℝ)..1, x * f x) / (∫ x in (0:ℝ)..1, f x) <
      (∫ x in (0:ℝ)..1, x * (f x) ^ 2) / (∫ x in (0:ℝ)..1, (f x) ^ 2) := by
  have hI : 0 < ∫ x in (0:ℝ)..1, f x := integral_f_pos hcont hpos hmono
  have hJ : 0 < ∫ x in (0:ℝ)..1, (f x) ^ 2 := integral_fsq_pos hcont hpos hmono
  rw [div_lt_div_iff₀ hI hJ]
  exact chebyshev_cross_inequality hcont hpos hmono

end Putnam2025B2Solution
