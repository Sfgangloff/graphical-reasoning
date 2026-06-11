import Mathlib

open scoped Real

noncomputable def putnam_1991_a5_solution : ℝ := 1 / 3

theorem putnam_1991_a5 :
    IsGreatest {t : ℝ | ∃ y : ℝ, 0 ≤ y ∧ y ≤ 1 ∧
      ∫ x in (0:ℝ)..y, Real.sqrt (x ^ 4 + (y - y ^ 2) ^ 2) = t}
      putnam_1991_a5_solution := by
  constructor
  · -- membership: y = 1 attains the value 1/3
    refine ⟨1, by norm_num, le_refl 1, ?_⟩
    have hcongr : (∫ x in (0:ℝ)..1, Real.sqrt (x ^ 4 + (1 - 1 ^ 2) ^ 2))
        = ∫ x in (0:ℝ)..1, x ^ 2 := by
      apply intervalIntegral.integral_congr
      intro x hx
      simp only
      rw [show (1:ℝ) - 1 ^ 2 = 0 by ring, show (0:ℝ) ^ 2 = 0 by ring, add_zero,
          show x ^ 4 = (x ^ 2) ^ 2 by ring, Real.sqrt_sq (sq_nonneg x)]
    rw [hcongr, integral_pow]
    norm_num [putnam_1991_a5_solution]
  · -- upper bound: every value is ≤ 1/3
    rintro t ⟨y, hy0, hy1, rfl⟩
    show (∫ x in (0:ℝ)..y, Real.sqrt (x ^ 4 + (y - y ^ 2) ^ 2)) ≤ putnam_1991_a5_solution
    have hc : (0:ℝ) ≤ y - y ^ 2 := by nlinarith
    have hcont1 : Continuous (fun x : ℝ => Real.sqrt (x ^ 4 + (y - y ^ 2) ^ 2)) := by
      fun_prop
    have hcont2 : Continuous (fun x : ℝ => x ^ 2 + (y - y ^ 2)) := by fun_prop
    have hmono : (∫ x in (0:ℝ)..y, Real.sqrt (x ^ 4 + (y - y ^ 2) ^ 2))
        ≤ ∫ x in (0:ℝ)..y, (x ^ 2 + (y - y ^ 2)) := by
      apply intervalIntegral.integral_mono_on hy0
        (hcont1.intervalIntegrable _ _) (hcont2.intervalIntegrable _ _)
      intro x hx
      have hsum : (0:ℝ) ≤ x ^ 2 + (y - y ^ 2) := add_nonneg (sq_nonneg x) hc
      calc Real.sqrt (x ^ 4 + (y - y ^ 2) ^ 2)
          ≤ Real.sqrt ((x ^ 2 + (y - y ^ 2)) ^ 2) := by
            apply Real.sqrt_le_sqrt; nlinarith [sq_nonneg x, hc]
        _ = x ^ 2 + (y - y ^ 2) := Real.sqrt_sq hsum
    have hval : (∫ x in (0:ℝ)..y, (x ^ 2 + (y - y ^ 2))) = y ^ 3 / 3 + (y - y ^ 2) * y := by
      rw [intervalIntegral.integral_add ((continuous_pow 2).intervalIntegrable _ _)
            (continuous_const.intervalIntegrable _ _),
          integral_pow, intervalIntegral.integral_const]
      simp
      ring
    rw [hval] at hmono
    have hpoly : y ^ 3 / 3 + (y - y ^ 2) * y ≤ putnam_1991_a5_solution := by
      unfold putnam_1991_a5_solution
      nlinarith [sq_nonneg (y - 1), hy0]
    linarith
