import Mathlib

open Real

noncomputable def putnam_1986_a1_solution : ℝ := 18

theorem putnam_1986_a1 :
    IsGreatest ((fun x : ℝ => x^3 - 3*x) '' {x : ℝ | x^4 + 36 ≤ 13 * x^2})
      putnam_1986_a1_solution := by
  refine ⟨⟨3, ?_, ?_⟩, ?_⟩
  · -- 3 ∈ {x : x^4 + 36 ≤ 13 * x^2}
    show (3:ℝ)^4 + 36 ≤ 13 * 3^2
    norm_num
  · -- f 3 = 18
    show (3:ℝ)^3 - 3*3 = putnam_1986_a1_solution
    unfold putnam_1986_a1_solution
    norm_num
  · -- 18 is an upper bound
    rintro y ⟨x, hx, rfl⟩
    show x^3 - 3*x ≤ putnam_1986_a1_solution
    unfold putnam_1986_a1_solution
    have hx' : x^4 + 36 ≤ 13 * x^2 := hx
    have h1 : x^2 ≤ 9 := by nlinarith [sq_nonneg (x^2 - 9), hx']
    have h2 : x ≤ 3 := by nlinarith [sq_nonneg (x - 3), h1]
    have h3 : x^2 + 3*x + 6 ≥ 0 := by nlinarith [sq_nonneg (x + 3/2)]
    have h4 : (3 - x) * (x^2 + 3*x + 6) ≥ 0 := mul_nonneg (by linarith) h3
    nlinarith [h4]
