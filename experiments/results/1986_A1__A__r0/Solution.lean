import Mathlib

noncomputable def putnam_1986_a1_solution : ℝ := 18

theorem putnam_1986_a1 :
    IsGreatest {y : ℝ | ∃ x : ℝ, x^4 + 36 ≤ 13 * x^2 ∧ y = x^3 - 3*x} putnam_1986_a1_solution := by
  constructor
  · refine ⟨3, ?_, ?_⟩
    · norm_num
    · show (putnam_1986_a1_solution : ℝ) = 3^3 - 3*3
      unfold putnam_1986_a1_solution
      norm_num
  · rintro y ⟨x, hx, rfl⟩
    have h1 : x^2 ≤ 9 := by nlinarith [sq_nonneg (x^2 - 9), hx]
    have h2 : x ≤ 3 := by nlinarith [sq_nonneg (x - 3), h1]
    have h3 : (0:ℝ) ≤ x^2 + 3*x + 6 := by nlinarith [sq_nonneg (2*x + 3)]
    have h4 : (x - 3) * (x^2 + 3*x + 6) ≤ 0 :=
      mul_nonpos_of_nonpos_of_nonneg (by linarith) h3
    show x^3 - 3*x ≤ putnam_1986_a1_solution
    unfold putnam_1986_a1_solution
    nlinarith [h4]
