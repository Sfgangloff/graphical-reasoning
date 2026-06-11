import Mathlib

open scoped Real

noncomputable def putnam_1991_a5_solution : ℝ := 1 / 3

theorem putnam_1991_a5 :
    IsGreatest
      {t : ℝ | ∃ y ∈ Set.Icc (0:ℝ) 1,
        t = ∫ x in (0:ℝ)..y, Real.sqrt (x ^ 4 + (y - y ^ 2) ^ 2)}
      putnam_1991_a5_solution := by
  constructor
  · -- membership: achieved at y = 1
    refine ⟨1, ⟨by norm_num, le_refl 1⟩, ?_⟩
    have hcongr : (∫ x in (0:ℝ)..1, Real.sqrt (x ^ 4 + ((1:ℝ) - 1 ^ 2) ^ 2))
        = ∫ x in (0:ℝ)..1, x ^ 2 := by
      apply intervalIntegral.integral_congr
      intro x hx
      show Real.sqrt (x ^ 4 + ((1:ℝ) - 1 ^ 2) ^ 2) = x ^ 2
      have : x ^ 4 + ((1:ℝ) - 1 ^ 2) ^ 2 = (x ^ 2) ^ 2 := by ring
      rw [this, Real.sqrt_sq (sq_nonneg x)]
    rw [putnam_1991_a5_solution, hcongr, integral_pow]
    norm_num
  · -- upper bound
    rintro t ⟨y, ⟨hy0, hy1⟩, rfl⟩
    have hyy : (0:ℝ) ≤ y - y ^ 2 := by nlinarith
    have key : ∀ x ∈ Set.Icc (0:ℝ) y,
        Real.sqrt (x ^ 4 + (y - y ^ 2) ^ 2) ≤ x ^ 2 + (y - y ^ 2) := by
      intro x hx
      have hB : (0:ℝ) ≤ x ^ 2 + (y - y ^ 2) := by positivity
      rw [show x ^ 2 + (y - y ^ 2) = Real.sqrt ((x ^ 2 + (y - y ^ 2)) ^ 2) from
            (Real.sqrt_sq hB).symm]
      apply Real.sqrt_le_sqrt
      nlinarith [mul_nonneg (sq_nonneg x) hyy]
    have hmono :
        (∫ x in (0:ℝ)..y, Real.sqrt (x ^ 4 + (y - y ^ 2) ^ 2))
          ≤ ∫ x in (0:ℝ)..y, (x ^ 2 + (y - y ^ 2)) := by
      apply intervalIntegral.integral_mono_on hy0
      · apply Continuous.intervalIntegrable
        fun_prop
      · apply Continuous.intervalIntegrable
        fun_prop
      · exact key
    have hcomp :
        (∫ x in (0:ℝ)..y, (x ^ 2 + (y - y ^ 2))) = y ^ 3 / 3 + (y - y ^ 2) * y := by
      rw [intervalIntegral.integral_add ((continuous_pow 2).intervalIntegrable _ _)
            (continuous_const.intervalIntegrable _ _)]
      rw [integral_pow, intervalIntegral.integral_const]
      simp
      ring
    rw [hcomp] at hmono
    have hfin : y ^ 3 / 3 + (y - y ^ 2) * y ≤ (1:ℝ) / 3 := by nlinarith
    exact le_trans hmono hfin
