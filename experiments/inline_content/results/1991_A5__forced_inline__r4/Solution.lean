import Mathlib

open Real

noncomputable def putnam_1991_a5_solution : ℝ := 1 / 3

theorem putnam_1991_a5 :
    IsGreatest
      {t : ℝ | ∃ y ∈ Set.Icc (0:ℝ) 1, t = ∫ x in (0:ℝ)..y, Real.sqrt (x ^ 4 + (y - y ^ 2) ^ 2)}
      putnam_1991_a5_solution := by
  constructor
  · -- membership: take y = 1, integral becomes ∫ x^2 = 1/3
    refine ⟨1, ⟨by norm_num, le_refl _⟩, ?_⟩
    have hcong : (∫ x in (0:ℝ)..1, Real.sqrt (x ^ 4 + (1 - 1 ^ 2) ^ 2))
               = ∫ x in (0:ℝ)..1, x ^ 2 := by
      apply intervalIntegral.integral_congr
      intro x hx
      simp only
      rw [show (1 - (1:ℝ) ^ 2) ^ 2 = 0 by norm_num, add_zero,
          show x ^ 4 = (x ^ 2) ^ 2 by ring, Real.sqrt_sq (sq_nonneg x)]
    show putnam_1991_a5_solution = _
    rw [hcong, integral_pow]
    norm_num [putnam_1991_a5_solution]
  · -- upper bound
    rintro t ⟨y, ⟨hy0, hy1⟩, rfl⟩
    set c := y - y ^ 2 with hc
    have hcnonneg : 0 ≤ c := by rw [hc]; nlinarith
    have hbound : (∫ x in (0:ℝ)..y, Real.sqrt (x ^ 4 + c ^ 2))
                ≤ ∫ x in (0:ℝ)..y, (x ^ 2 + c) := by
      apply intervalIntegral.integral_mono_on hy0
      · exact (by fun_prop : Continuous fun x : ℝ => Real.sqrt (x ^ 4 + c ^ 2)).intervalIntegrable _ _
      · exact (by fun_prop : Continuous fun x : ℝ => x ^ 2 + c).intervalIntegrable _ _
      · intro x hx
        have hle : x ^ 4 + c ^ 2 ≤ (x ^ 2 + c) ^ 2 := by nlinarith [sq_nonneg x, hcnonneg]
        calc Real.sqrt (x ^ 4 + c ^ 2) ≤ Real.sqrt ((x ^ 2 + c) ^ 2) := Real.sqrt_le_sqrt hle
          _ = x ^ 2 + c := Real.sqrt_sq (by positivity)
    have hval : (∫ x in (0:ℝ)..y, (x ^ 2 + c)) = y ^ 3 / 3 + c * y := by
      rw [intervalIntegral.integral_add ((continuous_pow 2).intervalIntegrable _ _)
            intervalIntegrable_const, integral_pow, intervalIntegral.integral_const]
      simp
      ring
    show _ ≤ putnam_1991_a5_solution
    rw [show putnam_1991_a5_solution = (1:ℝ) / 3 from rfl]
    calc (∫ x in (0:ℝ)..y, Real.sqrt (x ^ 4 + c ^ 2))
        ≤ ∫ x in (0:ℝ)..y, (x ^ 2 + c) := hbound
      _ = y ^ 3 / 3 + c * y := hval
      _ ≤ 1 / 3 := by
          rw [hc]
          nlinarith [mul_nonneg (sq_nonneg (1 - y)) (by linarith : (0:ℝ) ≤ 1 + 2 * y)]
