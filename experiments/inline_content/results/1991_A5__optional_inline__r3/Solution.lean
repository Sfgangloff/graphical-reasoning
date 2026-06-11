import Mathlib

open scoped Real

noncomputable def putnam_1991_a5_solution : ℝ := 1 / 3

theorem putnam_1991_a5 :
    IsGreatest
      {t : ℝ | ∃ y ∈ Set.Icc (0 : ℝ) 1,
        t = ∫ x in (0 : ℝ)..y, Real.sqrt (x ^ 4 + (y - y ^ 2) ^ 2)}
      putnam_1991_a5_solution := by
  constructor
  · -- membership: achieved at y = 1
    refine ⟨1, ⟨by norm_num, le_refl 1⟩, ?_⟩
    have hcong : (∫ x in (0:ℝ)..1, Real.sqrt (x ^ 4 + (1 - 1 ^ 2) ^ 2))
        = ∫ x in (0:ℝ)..1, x ^ 2 := by
      apply intervalIntegral.integral_congr
      intro x _
      simp only
      rw [show (1:ℝ) - 1 ^ 2 = 0 by ring, show x ^ 4 + (0:ℝ) ^ 2 = (x ^ 2) ^ 2 by ring]
      exact Real.sqrt_sq (sq_nonneg x)
    rw [hcong, integral_pow]
    norm_num [putnam_1991_a5_solution]
  · -- upper bound
    rintro t ⟨y, ⟨hy0, hy1⟩, rfl⟩
    have hc : 0 ≤ y - y ^ 2 := by nlinarith
    have step1 : (∫ x in (0:ℝ)..y, Real.sqrt (x ^ 4 + (y - y ^ 2) ^ 2))
        ≤ ∫ x in (0:ℝ)..y, (x ^ 2 + (y - y ^ 2)) := by
      apply intervalIntegral.integral_mono_on hy0
      · apply Continuous.intervalIntegrable
        fun_prop
      · apply Continuous.intervalIntegrable
        fun_prop
      · intro x _
        have hrhs : 0 ≤ x ^ 2 + (y - y ^ 2) := add_nonneg (sq_nonneg x) hc
        rw [← Real.sqrt_sq hrhs]
        apply Real.sqrt_le_sqrt
        nlinarith [mul_nonneg (sq_nonneg x) hc]
    have step2 : (∫ x in (0:ℝ)..y, (x ^ 2 + (y - y ^ 2)))
        = y ^ 3 / 3 + y * (y - y ^ 2) := by
      rw [intervalIntegral.integral_add ((continuous_pow 2).intervalIntegrable _ _)
        (continuous_const.intervalIntegrable _ _),
        integral_pow, intervalIntegral.integral_const]
      simp
      ring
    rw [step2] at step1
    show _ ≤ putnam_1991_a5_solution
    rw [putnam_1991_a5_solution]
    nlinarith [step1, mul_nonneg (sq_nonneg (y - 1)) (by linarith : (0:ℝ) ≤ 2 * y + 1)]
