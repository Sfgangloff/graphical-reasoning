import Mathlib

open Real

noncomputable def putnam_1986_a1_solution : ℝ := 18

theorem putnam_1986_a1 :
    IsGreatest
      ((fun x : ℝ => x^3 - 3*x) '' {x : ℝ | x^4 + 36 ≤ 13 * x^2})
      putnam_1986_a1_solution := by
  constructor
  · refine ⟨3, ?_, ?_⟩
    · show (3:ℝ)^4 + 36 ≤ 13 * 3^2
      norm_num
    · show (3:ℝ)^3 - 3*3 = putnam_1986_a1_solution
      norm_num [putnam_1986_a1_solution]
  · rintro y ⟨x, hx, rfl⟩
    simp only [Set.mem_setOf_eq] at hx
    -- hx : x^4 + 36 ≤ 13 * x^2
    have hxle : x ≤ 3 := by
      by_contra h
      push_neg at h
      have hx2 : x^2 > 9 := by nlinarith
      have h1 : x^2 - 9 > 0 := by linarith
      have h2 : x^2 - 4 > 0 := by linarith
      have hprod : (x^2 - 9) * (x^2 - 4) > 0 := mul_pos h1 h2
      have hexp : x^4 - 13 * x^2 + 36 > 0 := by nlinarith [hprod]
      linarith
    have hkey : (0:ℝ) ≤ (3 - x) * (2*x + 3)^2 :=
      mul_nonneg (by linarith) (sq_nonneg _)
    show x^3 - 3*x ≤ putnam_1986_a1_solution
    show x^3 - 3*x ≤ 18
    nlinarith [hxle, hkey]
