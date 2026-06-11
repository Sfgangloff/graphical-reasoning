import Mathlib

open MeasureTheory intervalIntegral

noncomputable def putnam_1993_a1_solution : ℝ := 4 / 9

/-- The horizontal line `y = c` meets `y = 2x - 3x^3` in the first quadrant at
two points `x₁ < x₂`.  The region between the `y`-axis, the line and the curve
(area `∫₀^{x₁} (c - f)`) has the same area as the region under the curve and above
the line (area `∫_{x₁}^{x₂} (f - c)`) exactly when `c = 4/9`. -/
theorem putnam_1993_a1 :
    putnam_1993_a1_solution ∈ Set.Ioo (0 : ℝ) (4 * Real.sqrt 2 / 9) ∧
    ∃ x₁ x₂ : ℝ, 0 < x₁ ∧ x₁ < x₂ ∧
      2 * x₁ - 3 * x₁ ^ 3 = putnam_1993_a1_solution ∧
      2 * x₂ - 3 * x₂ ^ 3 = putnam_1993_a1_solution ∧
      (∫ x in (0 : ℝ)..x₁, (putnam_1993_a1_solution - (2 * x - 3 * x ^ 3))) =
      (∫ x in x₁..x₂, ((2 * x - 3 * x ^ 3) - putnam_1993_a1_solution)) := by
  unfold putnam_1993_a1_solution
  have hs3 : Real.sqrt 3 ^ 2 = 3 := Real.sq_sqrt (by norm_num)
  have hs2 : Real.sqrt 2 ^ 2 = 2 := Real.sq_sqrt (by norm_num)
  have hs3nn : 0 ≤ Real.sqrt 3 := Real.sqrt_nonneg 3
  have hs2nn : 0 ≤ Real.sqrt 2 := Real.sqrt_nonneg 2
  -- closed form for ∫ (4/9 - (2x - 3x^3))
  have key : ∀ a b : ℝ, (∫ x in a..b, (4 / 9 - (2 * x - 3 * x ^ 3)) : ℝ) =
      (4 / 9 * b - b ^ 2 + 3 / 4 * b ^ 4) - (4 / 9 * a - a ^ 2 + 3 / 4 * a ^ 4) := by
    intro a b
    have hderiv : ∀ x ∈ Set.uIcc a b,
        HasDerivAt (fun y => 4 / 9 * y - y ^ 2 + 3 / 4 * y ^ 4)
          (4 / 9 - (2 * x - 3 * x ^ 3)) x := by
      intro x _
      have h := (((hasDerivAt_id x).const_mul (4 / 9 : ℝ)).sub
        (hasDerivAt_pow 2 x)).add ((hasDerivAt_pow 4 x).const_mul (3 / 4 : ℝ))
      convert h using 1
      push_cast
      ring
    have hint : IntervalIntegrable (fun x => 4 / 9 - (2 * x - 3 * x ^ 3)) volume a b := by
      apply Continuous.intervalIntegrable
      fun_prop
    rw [intervalIntegral.integral_eq_sub_of_hasDerivAt hderiv hint]
  refine ⟨⟨by norm_num, ?_⟩, (Real.sqrt 3 - 1) / 3, 2 / 3, ?_, ?_, ?_, ?_, ?_⟩
  · nlinarith [hs2, hs2nn]
  · nlinarith [hs3, hs3nn]
  · nlinarith [hs3, hs3nn]
  · linear_combination ((3 - Real.sqrt 3) / 9) * hs3
  · norm_num
  · -- the two areas are equal
    have hneg : (∫ x in ((Real.sqrt 3 - 1) / 3)..(2 / 3), ((2 * x - 3 * x ^ 3) - 4 / 9)) =
        -(∫ x in ((Real.sqrt 3 - 1) / 3)..(2 / 3), (4 / 9 - (2 * x - 3 * x ^ 3))) := by
      rw [← intervalIntegral.integral_neg]
      congr 1
      ext x
      ring
    rw [hneg, key, key]
    ring
