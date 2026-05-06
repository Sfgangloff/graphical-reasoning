import Mathlib

open Real Set MeasureTheory intervalIntegral

noncomputable def putnam_1991_a5_solution : ℝ := 1/3

theorem putnam_1991_a5 :
    IsGreatest
      {I : ℝ | ∃ y ∈ Icc (0:ℝ) 1, I = ∫ x in (0:ℝ)..y, Real.sqrt (x^4 + (y - y^2)^2)}
      putnam_1991_a5_solution := by
  constructor
  · -- 1/3 is achieved at y = 1
    refine ⟨1, ⟨zero_le_one, le_refl 1⟩, ?_⟩
    unfold putnam_1991_a5_solution
    have h1 : ∀ x : ℝ, Real.sqrt (x^4 + ((1:ℝ) - 1^2)^2) = x^2 := by
      intro x
      have hzero : ((1:ℝ) - 1^2)^2 = 0 := by ring
      rw [hzero, add_zero]
      have hx4 : x^4 = (x^2)^2 := by ring
      rw [hx4, Real.sqrt_sq (sq_nonneg x)]
    simp_rw [h1]
    rw [integral_pow]
    norm_num
  · -- 1/3 is an upper bound
    rintro I ⟨y, ⟨hy0, hy1⟩, hI⟩
    subst hI
    have hyy : 0 ≤ y - y^2 := by nlinarith
    -- Step 1: bound integrand by x^2 + (y - y^2)
    have step1 : ∫ x in (0:ℝ)..y, Real.sqrt (x^4 + (y - y^2)^2) ≤
                 ∫ x in (0:ℝ)..y, (x^2 + (y - y^2)) := by
      apply intervalIntegral.integral_mono_on hy0
      · apply ContinuousOn.intervalIntegrable
        apply Continuous.continuousOn
        exact ((continuous_pow 4).add continuous_const).sqrt
      · apply ContinuousOn.intervalIntegrable
        apply Continuous.continuousOn
        exact (continuous_pow 2).add continuous_const
      · intro x _
        have hpos : 0 ≤ x^2 + (y - y^2) := add_nonneg (sq_nonneg x) hyy
        have hsq : x^4 + (y - y^2)^2 ≤ (x^2 + (y - y^2))^2 := by nlinarith [sq_nonneg x, hyy]
        rw [show x^2 + (y - y^2) = Real.sqrt ((x^2 + (y - y^2))^2) from
              (Real.sqrt_sq hpos).symm]
        exact Real.sqrt_le_sqrt hsq
    -- Step 2: compute the polynomial integral
    have step2 : ∫ x in (0:ℝ)..y, (x^2 + (y - y^2)) = y^3/3 + y^2 * (1 - y) := by
      rw [intervalIntegral.integral_add
            ((continuous_pow 2).intervalIntegrable _ _)
            (continuous_const.intervalIntegrable _ _)]
      rw [integral_pow, intervalIntegral.integral_const]
      simp
      ring
    -- Step 3: y^3/3 + y^2(1-y) ≤ 1/3
    have step3 : y^3/3 + y^2 * (1 - y) ≤ (1:ℝ)/3 := by
      nlinarith [sq_nonneg (1 - y), mul_nonneg (sq_nonneg (1-y)) (by linarith : (0:ℝ) ≤ 1 + 2*y)]
    show ∫ x in (0:ℝ)..y, Real.sqrt (x^4 + (y - y^2)^2) ≤ putnam_1991_a5_solution
    unfold putnam_1991_a5_solution
    linarith [step1, step2.le, step2.ge, step3]
