import Mathlib

open intervalIntegral

noncomputable def putnam_1993_a1_solution : ℝ := 4 / 9

theorem putnam_1993_a1 :
    0 < putnam_1993_a1_solution ∧ putnam_1993_a1_solution < 4 * Real.sqrt 2 / 9 ∧
    ∃ x₁ x₂ : ℝ, 0 < x₁ ∧ x₁ < x₂ ∧
      2 * x₁ - 3 * x₁ ^ 3 = putnam_1993_a1_solution ∧
      2 * x₂ - 3 * x₂ ^ 3 = putnam_1993_a1_solution ∧
      (∫ x in (0:ℝ)..x₁, (putnam_1993_a1_solution - (2 * x - 3 * x ^ 3))) =
        ∫ x in x₁..x₂, ((2 * x - 3 * x ^ 3) - putnam_1993_a1_solution) := by
  unfold putnam_1993_a1_solution
  -- antiderivative of (4/9 - (2x - 3x^3))
  have hF : ∀ x : ℝ,
      HasDerivAt (fun y : ℝ => (4/9) * y - y ^ 2 + (3/4) * y ^ 4)
        ((4/9) - (2 * x - 3 * x ^ 3)) x := by
    intro x
    have e1 : HasDerivAt (fun y : ℝ => (4/9) * y) (4/9 : ℝ) x := by
      simpa using (hasDerivAt_id x).const_mul (4/9 : ℝ)
    have e2 : HasDerivAt (fun y : ℝ => y ^ 2) (2 * x) x := by
      simpa using hasDerivAt_pow 2 x
    have e3 : HasDerivAt (fun y : ℝ => (3/4) * y ^ 4) (3 * x ^ 3) x := by
      have h := (hasDerivAt_pow 4 x).const_mul (3/4 : ℝ)
      convert h using 1
      push_cast; ring
    convert (e1.sub e2).add e3 using 1
    ring
  -- key: evaluate the integral of (4/9 - (2x - 3x^3)) via the antiderivative
  have key : ∀ a b : ℝ,
      (∫ x in a..b, ((4/9) - (2 * x - 3 * x ^ 3))) =
        ((4/9) * b - b ^ 2 + (3/4) * b ^ 4) - ((4/9) * a - a ^ 2 + (3/4) * a ^ 4) := by
    intro a b
    apply integral_eq_sub_of_hasDerivAt
    · intro x _; exact hF x
    · apply Continuous.intervalIntegrable; fun_prop
  refine ⟨by norm_num, ?_, (Real.sqrt 3 - 1) / 3, 2 / 3, ?_, ?_, ?_, ?_, ?_⟩
  · -- 4/9 < 4*sqrt 2/9
    have h2 : (1 : ℝ) < Real.sqrt 2 := by
      have : Real.sqrt 1 < Real.sqrt 2 := Real.sqrt_lt_sqrt (by norm_num) (by norm_num)
      simpa using this
    nlinarith [h2]
  · -- 0 < (sqrt 3 - 1)/3
    have h3 : (1 : ℝ) < Real.sqrt 3 := by
      have : Real.sqrt 1 < Real.sqrt 3 := Real.sqrt_lt_sqrt (by norm_num) (by norm_num)
      simpa using this
    linarith
  · -- (sqrt 3 - 1)/3 < 2/3
    have h3 : Real.sqrt 3 < 3 := by
      have hs : Real.sqrt 3 ^ 2 = 3 := Real.sq_sqrt (by norm_num)
      nlinarith [Real.sqrt_nonneg 3, hs]
    linarith
  · -- 2*x₁ - 3*x₁^3 = 4/9
    have hs : Real.sqrt 3 ^ 2 = 3 := Real.sq_sqrt (by norm_num)
    linear_combination (-(Real.sqrt 3 - 3) / 9) * hs
  · -- 2*x₂ - 3*x₂^3 = 4/9
    norm_num
  · -- integral equality
    have rhs : (∫ x in (Real.sqrt 3 - 1) / 3..2 / 3, ((2 * x - 3 * x ^ 3) - 4/9)) =
        -(∫ x in (Real.sqrt 3 - 1) / 3..2 / 3, ((4/9) - (2 * x - 3 * x ^ 3))) := by
      rw [← intervalIntegral.integral_neg]
      congr 1; funext x; ring
    rw [rhs, key 0 ((Real.sqrt 3 - 1) / 3), key ((Real.sqrt 3 - 1) / 3) (2 / 3)]
    ring
