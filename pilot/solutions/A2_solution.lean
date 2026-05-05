import Mathlib

/-!
# Putnam 2025 A-2 — Solution

## Problem
Find the largest constant `a` and the smallest constant `b` such that
  `a · x · (π − x) ≤ sin x ≤ b · x · (π − x)` for all `x ∈ [0, π]`.

## Caveat about the original statement
The file `putnam/real_analysis/Y2025/A2.lean` states the problem with
`a = 4/π²` (largest) and `b = 1` (smallest). Both numbers are
**mathematically incorrect**:

* `4/π² ≈ 0.405` is **not** in the lower-bound set. Concrete
  counterexample at `x = π/6`:
    `(4/π²)·(π/6)·(5π/6) = 5/9 ≈ 0.556 > 1/2 = sin(π/6)`.
* `b = 1` is in the upper-bound set, but it is *not* the smallest:
  `4/π²` itself works (and is below 1).

The actual answers (visually confirmed by plotting `sin(x)/[x(π−x)]`):
* **Largest `a`** = `1/π`  (limit of `sin(x)/[x(π−x)]` as `x → 0⁺`).
* **Smallest `b`** = `4/π²` (max of `sin(x)/[x(π−x)]` at `x = π/2`).

## Strategy of this file
1. Prove that the original theorem (as stated in the year file) is false.
2. State the corrected theorem.
3. Prove the four parts of the corrected theorem. The two analytic
   inequalities are isolated as named lemmas with proof sketches in
   comments; the technical convexity arguments are left as `sorry`.
-/

namespace Putnam2025A2Solution

open Real Set

/-- The original statement is false: `4/π²` is **not** the greatest
element of `{a | ∀ x ∈ [0,π], a·x·(π−x) ≤ sin x}`, because it does not
even belong to that set (witness: `x = π/6`). -/
theorem original_a2_lower_false :
    ¬ IsGreatest {a : ℝ | ∀ x ∈ Set.Icc 0 Real.pi,
            a * x * (Real.pi - x) ≤ Real.sin x} (4 / Real.pi ^ 2) := by
  rintro ⟨hmem, _⟩
  have hπ : (0 : ℝ) < Real.pi := Real.pi_pos
  have hx : Real.pi / 6 ∈ Set.Icc (0 : ℝ) Real.pi :=
    ⟨by positivity, by linarith⟩
  have h := hmem (Real.pi / 6) hx
  rw [Real.sin_pi_div_six] at h
  -- h : (4/π²)·(π/6)·(π − π/6) ≤ 1/2,
  -- but the LHS evaluates to 5/9 > 1/2.
  have hπ_ne : Real.pi ≠ 0 := ne_of_gt hπ
  have heq : 4 / Real.pi ^ 2 * (Real.pi / 6) * (Real.pi - Real.pi / 6)
              = 5 / 9 := by
    field_simp
    ring
  rw [heq] at h
  norm_num at h

/-! ## The two hard analytic inequalities (left as `sorry`).

The pointwise inequalities below are the heart of the problem. They are
classical facts comparing `sin` to a parabolic envelope, and standard
proofs use the strict concavity of `sin` on `[0, π]` together with a sign
analysis of an auxiliary function's first and second derivatives. We
record the proof sketches here and leave the full formalization for
future work.
-/

/-- Lower bound: `(1/π)·x·(π−x) ≤ sin x` on `[0, π]`.

**Proof sketch.** Let `G(x) = sin x − x(π−x)/π`. Then
* `G(0) = G(π) = 0`;
* `G(π−x) = G(x)` (`G` is symmetric about `π/2`);
* `G'(x) = cos x − 1 + 2x/π`, so `G'(0) = G'(π/2) = G'(π) = 0`;
* `G''(x) = 2/π − sin x`. Hence `G'' ≥ 0` on `[0, x₁] ∪ [π−x₁, π]` and
  `G'' ≤ 0` on `[x₁, π−x₁]`, where `x₁ = arcsin(2/π) ∈ (0, π/2)`.

On `[0, x₁]`: `G''(x) ≥ 0` ⇒ `G'` non-decreasing ⇒ `G'(x) ≥ G'(0) = 0`
⇒ `G` non-decreasing ⇒ `G(x) ≥ G(0) = 0`.

On `[x₁, π/2]`: `G''(x) ≤ 0` ⇒ `G'` non-increasing. Since `G'(π/2) = 0`,
we have `G'(x) ≥ 0` on `[x₁, π/2]`, so `G` is still non-decreasing.

By symmetry, `G ≥ 0` on `[π/2, π]` as well. Hence `G ≥ 0` on `[0, π]`. -/
lemma sin_ge_lower (x : ℝ) (hx : x ∈ Set.Icc 0 Real.pi) :
    1 / Real.pi * x * (Real.pi - x) ≤ Real.sin x := by
  sorry

/-- Upper bound: `sin x ≤ (4/π²)·x·(π−x)` on `[0, π]`.

**Proof sketch.** Let `D(x) = (4/π²)·x·(π−x) − sin x`. Then
* `D(0) = D(π/2) = D(π) = 0` and `D(π−x) = D(x)`;
* `D'(x) = (4/π²)(π−2x) − cos x`, so `D'(0) = 4/π − 1 > 0` and
  `D'(π/2) = 0`;
* `D''(x) = sin x − 8/π²`. Hence `D''` is negative on a neighborhood of
  `0` and positive on a neighborhood of `π/2` (changes sign at
  `x₂ := arcsin(8/π²) ∈ (0, π/2)`).

A careful analysis shows `D'` has exactly one zero `x_M ∈ (0, x₂)` in
`[0, π/2]`: `D'` strictly decreases on `[0, x₂]` (concave segment)
from positive to negative, hits zero at `x_M`, then strictly increases
on `[x₂, π/2]` (convex segment) back to `0`. Therefore `D' ≥ 0` on
`[0, x_M]` and `D' ≤ 0` on `[x_M, π/2]`, which combined with
`D(0) = D(π/2) = 0` gives `D ≥ 0` on `[0, π/2]`. By symmetry the same
holds on `[π/2, π]`. -/
lemma sin_le_upper (x : ℝ) (hx : x ∈ Set.Icc 0 Real.pi) :
    Real.sin x ≤ 4 / Real.pi ^ 2 * x * (Real.pi - x) := by
  sorry

/-! ## The corrected theorem and its proof. -/

/-- Corrected Putnam 2025 A-2: the largest `a` and the smallest `b`
satisfying `a·x·(π−x) ≤ sin x ≤ b·x·(π−x)` on `[0, π]` are
`a = 1/π` and `b = 4/π²`. -/
theorem putnam_2025_a2_corrected :
    IsGreatest {a : ℝ | ∀ x ∈ Set.Icc 0 Real.pi,
        a * x * (Real.pi - x) ≤ Real.sin x} (1 / Real.pi) ∧
    IsLeast {b : ℝ | ∀ x ∈ Set.Icc 0 Real.pi,
        Real.sin x ≤ b * x * (Real.pi - x)} (4 / Real.pi ^ 2) := by
  have hπ : (0 : ℝ) < Real.pi := Real.pi_pos
  refine ⟨⟨?lower_mem, ?lower_max⟩, ⟨?upper_mem, ?upper_min⟩⟩
  case lower_mem =>
    -- `1/π ∈ S` is exactly the lower analytic inequality.
    intro x hx
    exact sin_ge_lower x hx
  case lower_max =>
    -- For any `a` with `a·x·(π−x) ≤ sin x` on `[0, π]`, `a ≤ 1/π`.
    -- If not, set `x₀ = (π − 1/a)/2`. Then `0 < x₀ < π/2`,
    -- `a(π − x₀) = (aπ + 1)/2 > 1`, so `a·x₀·(π−x₀) > x₀ ≥ sin x₀`,
    -- contradicting the membership inequality at `x₀`.
    intro a ha
    by_contra hgt
    rw [not_le] at hgt
    -- `hgt : 1/π < a`
    have ha_pos : 0 < a := lt_trans (by positivity) hgt
    have h_aπ_gt_1 : 1 < a * Real.pi := by
      have := (div_lt_iff₀ hπ).mp hgt
      linarith
    have h_inv_lt_pi : 1 / a < Real.pi :=
      (div_lt_iff₀ ha_pos).mpr (by linarith)
    let x₀ : ℝ := (Real.pi - 1 / a) / 2
    have hx₀_def : x₀ = (Real.pi - 1 / a) / 2 := rfl
    have hx₀_pos : 0 < x₀ := by
      have h1 : 0 < Real.pi - 1 / a := by linarith
      show 0 < (Real.pi - 1 / a) / 2
      linarith
    have hx₀_lt_pi : x₀ < Real.pi := by
      have h1 : 0 < 1 / a := by positivity
      show (Real.pi - 1 / a) / 2 < Real.pi
      linarith
    have hx₀_mem : x₀ ∈ Set.Icc (0 : ℝ) Real.pi :=
      ⟨le_of_lt hx₀_pos, le_of_lt hx₀_lt_pi⟩
    have h_pi_minus_x₀ : Real.pi - x₀ = (Real.pi + 1 / a) / 2 := by
      simp [hx₀_def]; ring
    have h_a_factor : 1 < a * (Real.pi - x₀) := by
      rw [h_pi_minus_x₀]
      have h1 : a * ((Real.pi + 1 / a) / 2) = (a * Real.pi + 1) / 2 := by
        field_simp
      rw [h1]
      linarith
    have h_strict : x₀ < a * x₀ * (Real.pi - x₀) := by
      have := mul_lt_mul_of_pos_left h_a_factor hx₀_pos
      -- this : x₀ * 1 < x₀ * (a * (π − x₀))
      nlinarith [hx₀_pos, h_a_factor]
    have h_sin_le : Real.sin x₀ ≤ x₀ := Real.sin_le (le_of_lt hx₀_pos)
    have h_mem := ha x₀ hx₀_mem
    linarith
  case upper_mem =>
    -- `4/π² ∈ T` is exactly the upper analytic inequality.
    intro x hx
    exact sin_le_upper x hx
  case upper_min =>
    -- For any `b` with `sin x ≤ b·x·(π−x)` on `[0, π]`, `4/π² ≤ b`.
    -- Use `x = π/2`: `sin(π/2) = 1 ≤ b·(π/2)·(π/2) = bπ²/4`,
    -- so `b ≥ 4/π²`.
    intro b hb
    have hpi2 : Real.pi / 2 ∈ Set.Icc (0 : ℝ) Real.pi :=
      ⟨by linarith, by linarith⟩
    have h := hb (Real.pi / 2) hpi2
    rw [Real.sin_pi_div_two] at h
    -- h : 1 ≤ b * (π/2) * (π − π/2)
    have hsq : b * (Real.pi / 2) * (Real.pi - Real.pi / 2)
                = b * Real.pi ^ 2 / 4 := by ring
    rw [hsq] at h
    -- h : 1 ≤ b · π² / 4
    have hπ_sq_pos : 0 < Real.pi ^ 2 := by positivity
    rw [div_le_iff₀ hπ_sq_pos]
    nlinarith [h, hπ_sq_pos]

end Putnam2025A2Solution
