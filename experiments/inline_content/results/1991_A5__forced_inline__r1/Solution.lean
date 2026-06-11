import Mathlib

open scoped Real

noncomputable def putnam_1991_a5_solution : ℝ := 1/3

theorem putnam_1991_a5 :
    IsGreatest {z : ℝ | ∃ y ∈ Set.Icc (0:ℝ) 1,
      z = ∫ x in (0:ℝ)..y, Real.sqrt (x^4 + (y - y^2)^2)}
      putnam_1991_a5_solution := by
  constructor
  · -- membership: take y = 1
    refine ⟨1, ⟨by norm_num, le_refl 1⟩, ?_⟩
    have hcong : (∫ x in (0:ℝ)..1, Real.sqrt (x^4 + ((1:ℝ) - 1^2)^2))
        = ∫ x in (0:ℝ)..1, x^2 := by
      apply intervalIntegral.integral_congr
      intro x hx
      show Real.sqrt (x^4 + ((1:ℝ) - 1^2)^2) = x^2
      rw [show ((1:ℝ) - 1^2) = 0 by norm_num,
          show x^4 + (0:ℝ)^2 = (x^2)^2 by ring, Real.sqrt_sq (sq_nonneg x)]
    rw [putnam_1991_a5_solution, hcong, integral_pow]
    norm_num
  · -- upper bound
    rintro z ⟨y, ⟨hy0, hy1⟩, rfl⟩
    rw [putnam_1991_a5_solution]
    have hc : 0 ≤ y - y^2 := by nlinarith
    have hcont1 : Continuous (fun x : ℝ => Real.sqrt (x^4 + (y - y^2)^2)) := by
      fun_prop
    have hub : (∫ x in (0:ℝ)..y, Real.sqrt (x^4 + (y - y^2)^2))
        ≤ ∫ x in (0:ℝ)..y, (x^2 + (y - y^2)) := by
      apply intervalIntegral.integral_mono_on hy0
          (hcont1.intervalIntegrable 0 y)
          ((by fun_prop : Continuous (fun x : ℝ => x^2 + (y - y^2))).intervalIntegrable 0 y)
      intro x hx
      have hpos : (0:ℝ) ≤ x^2 + (y - y^2) := add_nonneg (sq_nonneg x) hc
      have hsq : x^4 + (y - y^2)^2 ≤ (x^2 + (y - y^2))^2 := by
        nlinarith [mul_nonneg hc (sq_nonneg x)]
      calc Real.sqrt (x^4 + (y - y^2)^2)
          ≤ Real.sqrt ((x^2 + (y - y^2))^2) := Real.sqrt_le_sqrt hsq
        _ = x^2 + (y - y^2) := Real.sqrt_sq hpos
    have hint : (∫ x in (0:ℝ)..y, (x^2 + (y - y^2)))
        = y^3/3 + (y - y^2) * y := by
      rw [intervalIntegral.integral_add
            ((continuous_pow 2).intervalIntegrable 0 y)
            (continuous_const.intervalIntegrable 0 y),
          integral_pow, intervalIntegral.integral_const]
      simp
      ring
    rw [hint] at hub
    nlinarith [hub, sq_nonneg (1 - y), hy0, hy1]
