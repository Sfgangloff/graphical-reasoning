import Mathlib

open intervalIntegral

noncomputable def putnam_1993_a1_solution : ℝ := 4 / 9

/-- The horizontal line `y = c` meets `y = 2x - 3x^3` in the first quadrant at two
points `x₁ < x₂`.  The region bounded by the `y`-axis, the line and the curve has
area `∫₀^{x₁} (c - (2x-3x³))`, and the region under the curve above the line between
the two intersection points has area `∫_{x₁}^{x₂} ((2x-3x³) - c)`.  The value of `c`
making these two areas equal is `4/9`. -/
theorem putnam_1993_a1 :
    ∃ x₁ x₂ : ℝ, 0 < x₁ ∧ x₁ < x₂ ∧
      2 * x₁ - 3 * x₁ ^ 3 = putnam_1993_a1_solution ∧
      2 * x₂ - 3 * x₂ ^ 3 = putnam_1993_a1_solution ∧
      (∫ x in (0)..x₁, (putnam_1993_a1_solution - (2 * x - 3 * x ^ 3)))
        = (∫ x in x₁..x₂, ((2 * x - 3 * x ^ 3) - putnam_1993_a1_solution)) := by
  have hs : Real.sqrt 3 ^ 2 = 3 := Real.sq_sqrt (by norm_num)
  have hnn : (0 : ℝ) ≤ Real.sqrt 3 := Real.sqrt_nonneg 3
  refine ⟨(Real.sqrt 3 - 1) / 3, 2 / 3, ?_, ?_, ?_, ?_, ?_⟩
  · nlinarith [hs, hnn]
  · nlinarith [hs, hnn]
  · simp only [putnam_1993_a1_solution]
    linear_combination ((3 - Real.sqrt 3) / 9) * hs
  · simp only [putnam_1993_a1_solution]; norm_num
  · -- both integrals via the fundamental theorem of calculus
    have dF : ∀ x : ℝ,
        HasDerivAt (fun y : ℝ => putnam_1993_a1_solution * y - y ^ 2 + 3 / 4 * y ^ 4)
          (putnam_1993_a1_solution - (2 * x - 3 * x ^ 3)) x := by
      intro x
      have h := (((hasDerivAt_id x).const_mul putnam_1993_a1_solution).sub
        (hasDerivAt_pow 2 x)).add ((hasDerivAt_pow 4 x).const_mul (3 / 4 : ℝ))
      convert h using 1
      push_cast
      ring
    have dG : ∀ x : ℝ,
        HasDerivAt (fun y : ℝ => -(putnam_1993_a1_solution * y - y ^ 2 + 3 / 4 * y ^ 4))
          ((2 * x - 3 * x ^ 3) - putnam_1993_a1_solution) x := by
      intro x
      convert (dF x).neg using 1
      ring
    have contF : Continuous fun x : ℝ => putnam_1993_a1_solution - (2 * x - 3 * x ^ 3) := by
      fun_prop
    have contG : Continuous fun x : ℝ => (2 * x - 3 * x ^ 3) - putnam_1993_a1_solution := by
      fun_prop
    rw [integral_eq_sub_of_hasDerivAt (fun x _ => dF x) (contF.intervalIntegrable _ _),
        integral_eq_sub_of_hasDerivAt (fun x _ => dG x) (contG.intervalIntegrable _ _)]
    simp only [putnam_1993_a1_solution]
    ring
