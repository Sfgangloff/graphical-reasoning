import Mathlib

open scoped BigOperators

noncomputable def putnam_1991_a5_solution : ℝ := 1/3

theorem putnam_1991_a5 :
    IsGreatest {t : ℝ | ∃ y ∈ Set.Icc (0:ℝ) 1,
      t = ∫ x in (0:ℝ)..y, Real.sqrt (x^4 + (y - y^2)^2)} putnam_1991_a5_solution := by
  constructor
  · -- membership: take y = 1
    refine ⟨1, ⟨by norm_num, le_refl 1⟩, ?_⟩
    unfold putnam_1991_a5_solution
    rw [intervalIntegral.integral_congr (g := fun x => x^2)]
    · rw [integral_pow]; norm_num
    · intro x _
      show Real.sqrt (x^4 + ((1:ℝ) - 1^2)^2) = x^2
      rw [show (1:ℝ) - 1^2 = 0 by norm_num, show x^4 + (0:ℝ)^2 = (x^2)^2 by ring,
        Real.sqrt_sq (sq_nonneg x)]
  · -- upper bound
    rintro t ⟨y, ⟨hy0, hy1⟩, rfl⟩
    unfold putnam_1991_a5_solution
    have hc : 0 ≤ y - y^2 := by nlinarith
    calc ∫ x in (0:ℝ)..y, Real.sqrt (x^4 + (y - y^2)^2)
        ≤ ∫ x in (0:ℝ)..y, (x^2 + (y - y^2)) := by
          apply intervalIntegral.integral_mono_on hy0
          · apply Continuous.intervalIntegrable; fun_prop
          · apply Continuous.intervalIntegrable; fun_prop
          · intro x _
            have hx2 : 0 ≤ x^2 + (y - y^2) := by positivity
            rw [show x^2 + (y - y^2) = Real.sqrt ((x^2 + (y - y^2))^2) from
              (Real.sqrt_sq hx2).symm]
            apply Real.sqrt_le_sqrt
            nlinarith [mul_nonneg (sq_nonneg x) hc]
      _ = y^3/3 + (y - y^2) * y := by
          rw [intervalIntegral.integral_add, integral_pow, intervalIntegral.integral_const]
          · simp; ring
          · exact (continuous_pow 2).intervalIntegrable _ _
          · exact intervalIntegrable_const
      _ ≤ 1/3 := by nlinarith [mul_nonneg (sq_nonneg (y-1)) (by linarith : (0:ℝ) ≤ 2*y+1)]
