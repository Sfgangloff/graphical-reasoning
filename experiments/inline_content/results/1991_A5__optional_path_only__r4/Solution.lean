import Mathlib

noncomputable def putnam_1991_a5_solution : ℝ := 1 / 3

theorem putnam_1991_a5 :
    IsGreatest {Iy : ℝ | ∃ y ∈ Set.Icc (0 : ℝ) 1,
      Iy = ∫ x in (0 : ℝ)..y, Real.sqrt (x ^ 4 + (y - y ^ 2) ^ 2)}
      putnam_1991_a5_solution := by
  constructor
  · -- membership: achieved at y = 1
    refine ⟨1, ⟨by norm_num, le_refl 1⟩, ?_⟩
    have hcong : (∫ x in (0:ℝ)..1, Real.sqrt (x ^ 4 + ((1:ℝ) - 1 ^ 2) ^ 2))
        = ∫ x in (0:ℝ)..1, x ^ 2 := by
      refine intervalIntegral.integral_congr (fun x _ => ?_)
      have h0 : ((1:ℝ) - 1 ^ 2) = 0 := by norm_num
      rw [h0]
      simp only [ne_eq, OfNat.ofNat_ne_zero, not_false_eq_true, zero_pow, add_zero]
      rw [show x ^ 4 = (x ^ 2) ^ 2 by ring]
      exact Real.sqrt_sq (sq_nonneg x)
    rw [putnam_1991_a5_solution, hcong, integral_pow]
    norm_num
  · -- upper bound
    rintro t ⟨y, ⟨hy0, hy1⟩, rfl⟩
    have hc : 0 ≤ y - y ^ 2 := by nlinarith
    have hbound : (∫ x in (0:ℝ)..y, Real.sqrt (x ^ 4 + (y - y ^ 2) ^ 2))
        ≤ ∫ x in (0:ℝ)..y, (x ^ 2 + (y - y ^ 2)) := by
      apply intervalIntegral.integral_mono_on hy0
      · apply Continuous.intervalIntegrable
        fun_prop
      · apply Continuous.intervalIntegrable
        fun_prop
      · intro x _
        have hxc : x ^ 4 + (y - y ^ 2) ^ 2 ≤ (x ^ 2 + (y - y ^ 2)) ^ 2 := by
          nlinarith [sq_nonneg x, hc]
        calc Real.sqrt (x ^ 4 + (y - y ^ 2) ^ 2)
            ≤ Real.sqrt ((x ^ 2 + (y - y ^ 2)) ^ 2) := Real.sqrt_le_sqrt hxc
          _ = x ^ 2 + (y - y ^ 2) := Real.sqrt_sq (add_nonneg (sq_nonneg x) hc)
    have hval : (∫ x in (0:ℝ)..y, (x ^ 2 + (y - y ^ 2)))
        = y ^ 3 / 3 + (y - y ^ 2) * y := by
      rw [intervalIntegral.integral_add
        ((continuous_pow 2).intervalIntegrable 0 y)
        (continuous_const.intervalIntegrable 0 y),
        integral_pow, intervalIntegral.integral_const]
      simp
      ring
    rw [putnam_1991_a5_solution]
    calc (∫ x in (0:ℝ)..y, Real.sqrt (x ^ 4 + (y - y ^ 2) ^ 2))
        ≤ ∫ x in (0:ℝ)..y, (x ^ 2 + (y - y ^ 2)) := hbound
      _ = y ^ 3 / 3 + (y - y ^ 2) * y := hval
      _ ≤ 1 / 3 := by nlinarith [sq_nonneg (y - 1), hy0]
