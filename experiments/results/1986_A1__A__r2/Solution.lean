import Mathlib

noncomputable def putnam_1986_a1_solution : ℝ := 18

theorem putnam_1986_a1 :
    IsGreatest {y : ℝ | ∃ x : ℝ, x^4 + 36 ≤ 13*x^2 ∧ y = x^3 - 3*x}
      putnam_1986_a1_solution := by
  constructor
  · -- 18 ∈ S, witness x = 3
    refine ⟨3, ?_, ?_⟩
    · norm_num
    · unfold putnam_1986_a1_solution; norm_num
  · -- upper bound: x^3 - 3*x ≤ 18 whenever x^4 + 36 ≤ 13 x^2
    rintro y ⟨x, hx, rfl⟩
    show x^3 - 3*x ≤ putnam_1986_a1_solution
    unfold putnam_1986_a1_solution
    nlinarith [hx, sq_nonneg (x^2 - 9), sq_nonneg (x - 3), sq_nonneg (x + 3),
               sq_nonneg (x + 3/2), sq_nonneg x, sq_nonneg (x^2 - 4)]
