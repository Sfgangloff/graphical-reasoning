import Mathlib

open MeasureTheory

noncomputable def putnam_1993_a1_solution : ℝ := 4 / 9

/-- The horizontal line `y = c` meets the curve `y = 2x - 3x^3` in the first
quadrant at two points `x₁ < x₂`.  The region between the `y`-axis, the line
and the curve has area `∫_0^{x₁} (c - (2x-3x^3))` and the region under the
curve and above the line has area `∫_{x₁}^{x₂} ((2x-3x^3) - c)`.  These two
areas are equal exactly when `c = 4/9`. -/
theorem putnam_1993_a1 :
    0 < putnam_1993_a1_solution ∧
    putnam_1993_a1_solution < 4 * Real.sqrt 2 / 9 ∧
    ∃ x₁ x₂ : ℝ, 0 < x₁ ∧ x₁ < x₂ ∧
      2 * x₁ - 3 * x₁ ^ 3 = putnam_1993_a1_solution ∧
      2 * x₂ - 3 * x₂ ^ 3 = putnam_1993_a1_solution ∧
      (∫ x in (0:ℝ)..x₁, (putnam_1993_a1_solution - (2 * x - 3 * x ^ 3)))
        = (∫ x in x₁..x₂, ((2 * x - 3 * x ^ 3) - putnam_1993_a1_solution)) := by
  unfold putnam_1993_a1_solution
  have hsqrt2 : (1:ℝ) < Real.sqrt 2 := by
    have h : Real.sqrt 1 < Real.sqrt 2 := Real.sqrt_lt_sqrt (by norm_num) (by norm_num)
    simpa using h
  refine ⟨by norm_num, by linarith [hsqrt2], ?_⟩
  set s := Real.sqrt 3 with hs_def
  have hs : s ^ 2 = 3 := Real.sq_sqrt (by norm_num)
  have hs_nonneg : 0 ≤ s := Real.sqrt_nonneg 3
  have hs_gt1 : (1:ℝ) < s := by nlinarith [hs, hs_nonneg, sq_nonneg (s - 1)]
  have hs_lt3 : s < 3 := by nlinarith [hs, hs_nonneg, sq_nonneg (s - 3)]
  refine ⟨(s - 1) / 3, 2 / 3, by linarith, by linarith, ?_, ?_, ?_⟩
  · -- f x₁ = 4/9
    have hpoly : 2 * ((s - 1) / 3) - 3 * ((s - 1) / 3) ^ 3 - 4 / 9
        = ((3 - s) / 9) * (s ^ 2 - 3) := by ring
    have hzero : ((3 - s) / 9) * (s ^ 2 - 3) = 0 := by rw [hs]; ring
    linarith [hpoly, hzero]
  · -- f x₂ = 4/9
    norm_num
  · -- the two areas are equal
    have hg : Continuous (fun x : ℝ => (4:ℝ) / 9 - (2 * x - 3 * x ^ 3)) := by fun_prop
    have key : ∀ x : ℝ,
        HasDerivAt (fun t : ℝ => (4:ℝ) / 9 * t ^ 1 - t ^ 2 + 3 / 4 * t ^ 4)
          ((4:ℝ) / 9 - (2 * x - 3 * x ^ 3)) x := by
      intro x
      have h := (((hasDerivAt_pow 1 x).const_mul ((4:ℝ) / 9)).sub
        (hasDerivAt_pow 2 x)).add ((hasDerivAt_pow 4 x).const_mul ((3:ℝ) / 4))
      convert h using 1
      push_cast
      ring
    have hint : IntervalIntegrable (fun x : ℝ => (4:ℝ) / 9 - (2 * x - 3 * x ^ 3))
        volume 0 (2 / 3) := hg.intervalIntegrable _ _
    have hzero : (∫ x in (0:ℝ)..(2 / 3), ((4:ℝ) / 9 - (2 * x - 3 * x ^ 3))) = 0 := by
      rw [intervalIntegral.integral_eq_sub_of_hasDerivAt (fun x _ => key x) hint]
      norm_num
    have hI1 : IntervalIntegrable (fun x : ℝ => (4:ℝ) / 9 - (2 * x - 3 * x ^ 3))
        volume 0 ((s - 1) / 3) := hg.intervalIntegrable _ _
    have hI2 : IntervalIntegrable (fun x : ℝ => (4:ℝ) / 9 - (2 * x - 3 * x ^ 3))
        volume ((s - 1) / 3) (2 / 3) := hg.intervalIntegrable _ _
    have hadd := intervalIntegral.integral_add_adjacent_intervals hI1 hI2
    rw [hzero] at hadd
    have e2 : (∫ x in ((s - 1) / 3)..(2 / 3 : ℝ), ((2 * x - 3 * x ^ 3) - (4:ℝ) / 9))
        = - (∫ x in ((s - 1) / 3)..(2 / 3 : ℝ), ((4:ℝ) / 9 - (2 * x - 3 * x ^ 3))) := by
      rw [← intervalIntegral.integral_neg]
      apply intervalIntegral.integral_congr
      intro x _
      ring
    rw [e2]
    linarith [hadd]
