import Mathlib

open intervalIntegral

noncomputable def putnam_1993_a1_solution : ℝ := 4 / 9

theorem putnam_1993_a1 :
    ∃ x₁ x₂ : ℝ, 0 < x₁ ∧ x₁ < x₂ ∧
      2 * x₁ - 3 * x₁ ^ 3 = putnam_1993_a1_solution ∧
      2 * x₂ - 3 * x₂ ^ 3 = putnam_1993_a1_solution ∧
      (∫ x in (0:ℝ)..x₁, (putnam_1993_a1_solution - (2 * x - 3 * x ^ 3))) =
        (∫ x in x₁..x₂, ((2 * x - 3 * x ^ 3) - putnam_1993_a1_solution)) := by
  -- antiderivative of  (4/9 - (2x - 3x^3))  is  F x = 4/9*x - x^2 + 3/4*x^4
  have key : ∀ a b : ℝ,
      (∫ x in a..b, ((4 / 9 : ℝ) - (2 * x - 3 * x ^ 3))) =
        ((4 / 9) * b - b ^ 2 + 3 / 4 * b ^ 4) - ((4 / 9) * a - a ^ 2 + 3 / 4 * a ^ 4) := by
    intro a b
    have hderiv : ∀ x ∈ Set.uIcc a b,
        HasDerivAt (fun y : ℝ => (4 / 9) * y - y ^ 2 + 3 / 4 * y ^ 4)
          ((4 / 9 : ℝ) - (2 * x - 3 * x ^ 3)) x := by
      intro x _
      have h := (((hasDerivAt_id x).const_mul (4 / 9 : ℝ)).sub
        (hasDerivAt_pow 2 x)).add ((hasDerivAt_pow 4 x).const_mul (3 / 4 : ℝ))
      convert h using 1
      push_cast
      ring
    have hcont : IntervalIntegrable (fun x : ℝ => (4 / 9 : ℝ) - (2 * x - 3 * x ^ 3))
        MeasureTheory.volume a b := by
      apply Continuous.intervalIntegrable
      fun_prop
    rw [integral_eq_sub_of_hasDerivAt hderiv hcont]
  refine ⟨(Real.sqrt 3 - 1) / 3, 2 / 3, ?_, ?_, ?_, ?_, ?_⟩
  · have h3 : (1 : ℝ) < Real.sqrt 3 := by
      nlinarith [Real.sq_sqrt (show (0:ℝ) ≤ 3 by norm_num), Real.sqrt_nonneg 3]
    linarith
  · have h3 : Real.sqrt 3 < 3 := by
      nlinarith [Real.sq_sqrt (show (0:ℝ) ≤ 3 by norm_num), Real.sqrt_nonneg 3]
    linarith
  · -- 2*x₁ - 3*x₁^3 = 4/9  with x₁ = (√3-1)/3
    have hs : Real.sqrt 3 ^ 2 = 3 := Real.sq_sqrt (by norm_num)
    have : Real.sqrt 3 ^ 3 = 3 * Real.sqrt 3 := by
      rw [pow_succ, hs]
    rw [putnam_1993_a1_solution]
    field_simp
    nlinarith [hs, this]
  · rw [putnam_1993_a1_solution]; norm_num
  · rw [putnam_1993_a1_solution]
    rw [key 0 ((Real.sqrt 3 - 1) / 3)]
    have hneg : (∫ x in ((Real.sqrt 3 - 1) / 3)..(2 / 3 : ℝ),
        ((2 * x - 3 * x ^ 3) - (4 / 9 : ℝ))) =
        -(∫ x in ((Real.sqrt 3 - 1) / 3)..(2 / 3 : ℝ),
          ((4 / 9 : ℝ) - (2 * x - 3 * x ^ 3))) := by
      rw [← intervalIntegral.integral_neg]
      congr 1
      ext x
      ring
    rw [hneg, key ((Real.sqrt 3 - 1) / 3) (2 / 3)]
    ring_nf
