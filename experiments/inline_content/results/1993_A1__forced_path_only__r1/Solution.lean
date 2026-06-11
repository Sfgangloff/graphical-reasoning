import Mathlib

open intervalIntegral

noncomputable def putnam_1993_a1_solution : ℝ := 4 / 9

/-- Antiderivative of `c - (2x - 3x³)` with `c = 4/9`. -/
noncomputable def G93 (t : ℝ) : ℝ := (4 / 9) * t - t ^ 2 + (3 / 4) * t ^ 4

theorem putnam_1993_a1 :
    ∃ x₁ x₂ : ℝ, 0 < x₁ ∧ x₁ < x₂ ∧
      2 * x₁ - 3 * x₁ ^ 3 = putnam_1993_a1_solution ∧
      2 * x₂ - 3 * x₂ ^ 3 = putnam_1993_a1_solution ∧
      (∫ x in (0)..x₁, (putnam_1993_a1_solution - (2 * x - 3 * x ^ 3)))
        = (∫ x in (x₁)..x₂, ((2 * x - 3 * x ^ 3) - putnam_1993_a1_solution)) := by
  have hs2 : Real.sqrt 3 ^ 2 = 3 := Real.sq_sqrt (by norm_num)
  have hs0 : (0 : ℝ) ≤ Real.sqrt 3 := Real.sqrt_nonneg 3
  have hs1 : (1 : ℝ) < Real.sqrt 3 := by nlinarith [hs2, hs0]
  have hs3 : Real.sqrt 3 < 3 := by nlinarith [hs2, hs0]
  -- derivative of the antiderivative
  have hGderiv : ∀ x : ℝ,
      HasDerivAt G93 (putnam_1993_a1_solution - (2 * x - 3 * x ^ 3)) x := by
    intro x
    unfold G93 putnam_1993_a1_solution
    have h := (((hasDerivAt_id x).const_mul (4 / 9 : ℝ)).sub
      (hasDerivAt_pow 2 x)).add ((hasDerivAt_pow 4 x).const_mul (3 / 4 : ℝ))
    convert h using 1
    push_cast
    ring
  -- general FTC evaluation
  have hg : ∀ a b : ℝ,
      (∫ x in a..b, (putnam_1993_a1_solution - (2 * x - 3 * x ^ 3))) = G93 b - G93 a := by
    intro a b
    apply intervalIntegral.integral_eq_sub_of_hasDerivAt (fun x _ => hGderiv x)
    apply Continuous.intervalIntegrable
    fun_prop
  have hG0 : G93 0 = 0 := by unfold G93; norm_num
  have hGb : G93 (2 / 3) = 0 := by unfold G93; norm_num
  refine ⟨(Real.sqrt 3 - 1) / 3, 2 / 3, by linarith, by linarith, ?_, ?_, ?_⟩
  · unfold putnam_1993_a1_solution
    linear_combination ((3 - Real.sqrt 3) / 9) * hs2
  · unfold putnam_1993_a1_solution; norm_num
  · have hneg : (∫ x in ((Real.sqrt 3 - 1) / 3)..(2 / 3 : ℝ),
        ((2 * x - 3 * x ^ 3) - putnam_1993_a1_solution))
        = -(∫ x in ((Real.sqrt 3 - 1) / 3)..(2 / 3 : ℝ),
            (putnam_1993_a1_solution - (2 * x - 3 * x ^ 3))) := by
      rw [← intervalIntegral.integral_neg]
      congr 1
      ext x
      ring
    rw [hneg, hg, hg, hG0, hGb]
    ring
