import Mathlib

noncomputable abbrev putnam_1986_a1_solution : ℝ := 18

theorem putnam_1986_a1 :
    IsGreatest {y : ℝ | ∃ x : ℝ, x^4 + 36 ≤ 13*x^2 ∧ y = x^3 - 3*x} putnam_1986_a1_solution := by
  constructor
  · -- 18 is in the set, witness x = 3
    refine ⟨3, ?_, ?_⟩ <;> norm_num
  · -- 18 is an upper bound
    rintro y ⟨x, hx, hy⟩
    rw [hy]
    -- From x^4 + 36 ≤ 13 x^2, we get (x^2-4)(x^2-9) ≤ 0, hence x^2 ≤ 9, hence x ≤ 3.
    -- Then x^3 - 3x - 18 = (x-3)(x^2 + 3x + 6) ≤ 0 since x^2 + 3x + 6 > 0.
    nlinarith [sq_nonneg (x - 3), sq_nonneg (x + 3), sq_nonneg (x^2 - 9), sq_nonneg (x^2 - 4),
               sq_nonneg (2*x + 3), sq_nonneg (x*(x-3)), sq_nonneg ((x-3)*(x+3)),
               sq_nonneg (x^2 + 3*x + 6), hx]
