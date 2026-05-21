import Mathlib

open intervalIntegral MeasureTheory

noncomputable def putnam_1993_a1_solution : ℝ := 4 / 9

/-- The horizontal line `y = c` intersects the curve `y = 2x - 3x^3` in the first
quadrant.  Find `c` so that the areas of the two shaded regions are equal:  the
region bounded by the `y`-axis, the line `y = c` and the curve, and the region
under the curve and above the line between the two intersection points. -/
theorem putnam_1993_a1 :
    0 < putnam_1993_a1_solution ∧
    putnam_1993_a1_solution < 4 * Real.sqrt 2 / 9 ∧
    (∃ x1 x2 : ℝ, 0 < x1 ∧ x1 < x2 ∧
      2 * x1 - 3 * x1 ^ 3 = putnam_1993_a1_solution ∧
      2 * x2 - 3 * x2 ^ 3 = putnam_1993_a1_solution ∧
      (∫ x in (0:ℝ)..x1, (putnam_1993_a1_solution - (2 * x - 3 * x ^ 3))) =
        (∫ x in x1..x2, ((2 * x - 3 * x ^ 3) - putnam_1993_a1_solution))) := by
  unfold putnam_1993_a1_solution
  refine ⟨by norm_num, ?_, ?_⟩
  · -- 4/9 < 4 √2 / 9
    have h1 : (1:ℝ) < Real.sqrt 2 := by
      have h : Real.sqrt 1 < Real.sqrt 2 := Real.sqrt_lt_sqrt (by norm_num) (by norm_num)
      rwa [Real.sqrt_one] at h
    linarith
  · -- the existence of the two intersection points with equal areas
    have hs : Real.sqrt 3 ^ 2 = 3 := Real.sq_sqrt (by norm_num)
    have hs1 : (1:ℝ) < Real.sqrt 3 := by
      have h : Real.sqrt 1 < Real.sqrt 3 := Real.sqrt_lt_sqrt (by norm_num) (by norm_num)
      rwa [Real.sqrt_one] at h
    have hs2 : Real.sqrt 3 < 2 := by
      have h : Real.sqrt 3 < Real.sqrt 4 := Real.sqrt_lt_sqrt (by norm_num) (by norm_num)
      rwa [show (4:ℝ) = 2 ^ 2 by norm_num, Real.sqrt_sq (by norm_num : (0:ℝ) ≤ 2)] at h
    refine ⟨(Real.sqrt 3 - 1) / 3, 2 / 3, ?_, ?_, ?_, ?_, ?_⟩
    · -- 0 < x1
      linarith [hs1]
    · -- x1 < x2
      linarith [hs2]
    · -- 2*x1 - 3*x1^3 = 4/9
      linear_combination (-(Real.sqrt 3 - 3) / 9) * hs
    · -- 2*x2 - 3*x2^3 = 4/9
      norm_num
    · -- the equal-area condition
      have cont1 : Continuous (fun x : ℝ => (4:ℝ) / 9 - (2 * x - 3 * x ^ 3)) := by fun_prop
      have cont2 : Continuous (fun x : ℝ => (2 * x - 3 * x ^ 3) - (4:ℝ) / 9) := by fun_prop
      have D : ∀ x : ℝ,
          HasDerivAt (fun x : ℝ => (4/9) * x ^ 1 - x ^ 2 + (3/4) * x ^ 4)
            ((4:ℝ) / 9 - (2 * x - 3 * x ^ 3)) x := by
        intro x
        have h := (((hasDerivAt_pow 1 x).const_mul ((4:ℝ)/9)).sub
            (hasDerivAt_pow 2 x)).add ((hasDerivAt_pow 4 x).const_mul ((3:ℝ)/4))
        convert h using 2
        push_cast
        ring
      have E : ∀ x : ℝ,
          HasDerivAt (fun x : ℝ => x ^ 2 - (3/4) * x ^ 4 - (4/9) * x ^ 1)
            ((2 * x - 3 * x ^ 3) - (4:ℝ) / 9) x := by
        intro x
        have h := (((hasDerivAt_pow 2 x).sub
            ((hasDerivAt_pow 4 x).const_mul ((3:ℝ)/4))).sub
            ((hasDerivAt_pow 1 x).const_mul ((4:ℝ)/9)))
        convert h using 2
        push_cast
        ring
      rw [intervalIntegral.integral_eq_sub_of_hasDerivAt (fun x _ => D x)
            (cont1.intervalIntegrable _ _),
          intervalIntegral.integral_eq_sub_of_hasDerivAt (fun x _ => E x)
            (cont2.intervalIntegrable _ _)]
      ring
