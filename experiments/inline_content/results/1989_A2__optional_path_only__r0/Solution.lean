import Mathlib

open MeasureTheory

noncomputable def putnam_1989_a2_solution : ℝ → ℝ → ℝ :=
  fun a b : ℝ => (Real.exp (a ^ 2 * b ^ 2) - 1) / (a * b)

theorem putnam_1989_a2 (a b : ℝ) (abpos : a > 0 ∧ b > 0) :
    (∫ x in (0:ℝ)..a, ∫ y in (0:ℝ)..b,
      Real.exp (max (b ^ 2 * x ^ 2) (a ^ 2 * y ^ 2))) = putnam_1989_a2_solution a b := by
  sorry
