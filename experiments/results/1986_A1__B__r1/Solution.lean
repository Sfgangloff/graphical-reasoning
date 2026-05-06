import Mathlib

noncomputable abbrev putnam_1986_a1_solution : ℝ := 18

theorem putnam_1986_a1 :
    IsGreatest {y : ℝ | ∃ x : ℝ, x^4 + 36 ≤ 13 * x^2 ∧ y = x^3 - 3*x} putnam_1986_a1_solution := by
  constructor
  · refine ⟨3, ?_, ?_⟩ <;> norm_num
  · rintro y ⟨x, hx, hy⟩
    subst hy
    have h2 : x^2 ≤ 9 := by nlinarith [sq_nonneg (x^2 - 4), sq_nonneg (x^2 - 9), sq_nonneg x]
    have h3 : x ≤ 3 := by nlinarith [sq_nonneg (x - 3), sq_nonneg (x + 3), h2]
    have h4 : x^2 + 3*x + 6 ≥ 0 := by nlinarith [sq_nonneg (2*x + 3)]
    nlinarith [mul_nonneg (sub_nonneg.mpr h3) h4, h3, h4]
