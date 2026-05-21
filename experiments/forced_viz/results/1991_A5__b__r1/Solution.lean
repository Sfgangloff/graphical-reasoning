import Mathlib

open scoped Real

noncomputable def putnam_1991_a5_solution : ℝ := 1 / 3

theorem putnam_1991_a5 :
    IsGreatest
      {m : ℝ | ∃ y : ℝ, 0 ≤ y ∧ y ≤ 1 ∧
        (∫ x in (0:ℝ)..y, Real.sqrt (x ^ 4 + (y - y ^ 2) ^ 2)) = m}
      putnam_1991_a5_solution := by
  constructor
  · -- membership: y = 1 attains 1/3
    refine ⟨1, by norm_num, le_refl 1, ?_⟩
    have hcongr : (fun x : ℝ => Real.sqrt (x ^ 4 + ((1:ℝ) - 1 ^ 2) ^ 2))
        = (fun x : ℝ => x ^ 2) := by
      funext x
      have h0 : ((1:ℝ) - 1 ^ 2) ^ 2 = 0 := by norm_num
      rw [h0, add_zero, show x ^ 4 = (x ^ 2) ^ 2 by ring, Real.sqrt_sq (sq_nonneg x)]
    rw [hcongr, integral_pow]
    norm_num [putnam_1991_a5_solution]
  · -- upper bound
    rintro m ⟨y, hy0, hy1, rfl⟩
    have hyy : 0 ≤ y - y ^ 2 := by nlinarith
    calc (∫ x in (0:ℝ)..y, Real.sqrt (x ^ 4 + (y - y ^ 2) ^ 2))
        ≤ ∫ x in (0:ℝ)..y, (x ^ 2 + (y - y ^ 2)) := by
          apply intervalIntegral.integral_mono_on hy0
          · exact (Continuous.intervalIntegrable (by continuity) _ _)
          · exact (Continuous.intervalIntegrable (by continuity) _ _)
          · intro x hx
            have hxnn : (0:ℝ) ≤ x := hx.1
            have hrhs : (0:ℝ) ≤ x ^ 2 + (y - y ^ 2) := by positivity
            rw [show x ^ 2 + (y - y ^ 2) = Real.sqrt ((x ^ 2 + (y - y ^ 2)) ^ 2) by
              rw [Real.sqrt_sq hrhs]]
            apply Real.sqrt_le_sqrt
            nlinarith [sq_nonneg x, mul_nonneg (sq_nonneg x) hyy]
      _ = y ^ 3 / 3 + y * (y - y ^ 2) := by
          rw [intervalIntegral.integral_add
            (Continuous.intervalIntegrable (by continuity) _ _)
            (Continuous.intervalIntegrable (by continuity) _ _)]
          rw [integral_pow, intervalIntegral.integral_const]
          simp only [smul_eq_mul]
          ring
      _ ≤ putnam_1991_a5_solution := by
          unfold putnam_1991_a5_solution
          nlinarith [sq_nonneg (y - 1), hy0, hy1]
