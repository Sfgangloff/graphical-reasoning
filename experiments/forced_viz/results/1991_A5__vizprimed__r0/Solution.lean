import Mathlib

open intervalIntegral

noncomputable def putnam_1991_a5_solution : ℝ := 1 / 3

theorem putnam_1991_a5 :
    IsGreatest
      {t : ℝ | ∃ y : ℝ, 0 ≤ y ∧ y ≤ 1 ∧
        t = ∫ x in (0:ℝ)..y, Real.sqrt (x ^ 4 + (y - y ^ 2) ^ 2)}
      putnam_1991_a5_solution := by
  constructor
  · -- membership: the value 1/3 is attained at y = 1
    refine ⟨1, by norm_num, by norm_num, ?_⟩
    have hfun : (fun x : ℝ => Real.sqrt (x ^ 4 + ((1:ℝ) - 1 ^ 2) ^ 2))
        = fun x : ℝ => x ^ 2 := by
      funext x
      have h0 : ((1:ℝ) - 1 ^ 2) = 0 := by norm_num
      rw [h0]
      have hx4 : x ^ 4 = (x ^ 2) ^ 2 := by ring
      simp only [ne_eq, OfNat.ofNat_ne_zero, not_false_eq_true, zero_pow, add_zero, hx4]
      rw [Real.sqrt_sq_eq_abs, abs_of_nonneg (sq_nonneg x)]
    rw [putnam_1991_a5_solution]
    rw [hfun, integral_pow]
    norm_num
  · -- upper bound: every value is ≤ 1/3
    rintro t ⟨y, hy0, hy1, rfl⟩
    have hc : (0:ℝ) ≤ y - y ^ 2 := by nlinarith [hy0, hy1]
    have hbound : ∀ x : ℝ,
        Real.sqrt (x ^ 4 + (y - y ^ 2) ^ 2) ≤ x ^ 2 + (y - y ^ 2) := by
      intro x
      have hx4 : x ^ 4 = (x ^ 2) ^ 2 := by ring
      rw [hx4]
      calc Real.sqrt ((x ^ 2) ^ 2 + (y - y ^ 2) ^ 2)
          ≤ Real.sqrt ((x ^ 2 + (y - y ^ 2)) ^ 2) :=
            Real.sqrt_le_sqrt (by nlinarith [mul_nonneg (sq_nonneg x) hc])
        _ = x ^ 2 + (y - y ^ 2) := by
            rw [Real.sqrt_sq_eq_abs, abs_of_nonneg (add_nonneg (sq_nonneg x) hc)]
    have hint : (∫ x in (0:ℝ)..y, Real.sqrt (x ^ 4 + (y - y ^ 2) ^ 2))
        ≤ ∫ x in (0:ℝ)..y, (x ^ 2 + (y - y ^ 2)) := by
      apply intervalIntegral.integral_mono_on hy0
      · exact (Continuous.intervalIntegrable (by fun_prop) ..)
      · exact (Continuous.intervalIntegrable (by fun_prop) ..)
      · intro x _; exact hbound x
    have hval : (∫ x in (0:ℝ)..y, (x ^ 2 + (y - y ^ 2)))
        = y ^ 3 / 3 + y * (y - y ^ 2) := by
      rw [intervalIntegral.integral_add
            (Continuous.intervalIntegrable (by fun_prop) ..)
            (Continuous.intervalIntegrable (by fun_prop) ..),
          integral_pow, intervalIntegral.integral_const]
      push_cast
      ring
    rw [hval] at hint
    rw [putnam_1991_a5_solution]
    nlinarith [hint, hy0, hy1,
      mul_nonneg (sq_nonneg (y - 1)) (by linarith : (0:ℝ) ≤ 2 * y + 1)]
