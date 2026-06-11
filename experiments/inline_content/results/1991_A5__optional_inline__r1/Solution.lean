import Mathlib

open scoped BigOperators

noncomputable def putnam_1991_a5_solution : ℝ := 1/3

theorem putnam_1991_a5 :
    IsGreatest {t : ℝ | ∃ y : ℝ, 0 ≤ y ∧ y ≤ 1 ∧
      t = ∫ x in (0:ℝ)..y, Real.sqrt (x^4 + (y - y^2)^2)} putnam_1991_a5_solution := by
  constructor
  · -- membership: y = 1 attains 1/3
    refine ⟨1, by norm_num, by norm_num, ?_⟩
    have hcong : (∫ x in (0:ℝ)..1, Real.sqrt (x^4 + ((1:ℝ) - 1^2)^2))
        = ∫ x in (0:ℝ)..1, x^2 := by
      apply intervalIntegral.integral_congr
      intro x _
      have h0 : ((1:ℝ) - 1^2) = 0 := by norm_num
      rw [h0]
      simp only [ne_eq, OfNat.ofNat_ne_zero, not_false_eq_true, zero_pow, add_zero]
      rw [show x^4 = (x^2)^2 by ring]
      exact Real.sqrt_sq (sq_nonneg x)
    rw [hcong, integral_pow]
    norm_num [putnam_1991_a5_solution]
  · -- upper bound
    rintro t ⟨y, hy0, hy1, rfl⟩
    set c := y - y^2 with hc
    have hcnn : 0 ≤ c := by nlinarith [hy0, hy1]
    have hcont1 : Continuous fun x : ℝ => Real.sqrt (x^4 + c^2) := by fun_prop
    have hcont2 : Continuous fun x : ℝ => x^2 + c := by fun_prop
    have hle : (∫ x in (0:ℝ)..y, Real.sqrt (x^4 + c^2)) ≤ ∫ x in (0:ℝ)..y, (x^2 + c) := by
      apply intervalIntegral.integral_mono_on hy0
          (hcont1.intervalIntegrable _ _) (hcont2.intervalIntegrable _ _)
      intro x _
      rw [show x^4 = (x^2)^2 by ring]
      calc Real.sqrt ((x^2)^2 + c^2)
          ≤ Real.sqrt ((x^2 + c)^2) := by
            apply Real.sqrt_le_sqrt
            nlinarith [mul_nonneg (sq_nonneg x) hcnn]
        _ = x^2 + c := Real.sqrt_sq (by positivity)
    have hint : (∫ x in (0:ℝ)..y, (x^2 + c)) = y^3/3 + c*y := by
      rw [intervalIntegral.integral_add
            ((continuous_pow 2).intervalIntegrable _ _)
            (continuous_const.intervalIntegrable _ _),
          integral_pow, intervalIntegral.integral_const]
      simp only [smul_eq_mul]
      ring
    calc (∫ x in (0:ℝ)..y, Real.sqrt (x^4 + c^2))
        ≤ ∫ x in (0:ℝ)..y, (x^2 + c) := hle
      _ = y^3/3 + c*y := hint
      _ ≤ putnam_1991_a5_solution := by
            simp only [putnam_1991_a5_solution, hc]
            nlinarith [mul_nonneg (sq_nonneg (1-y)) (by linarith : (0:ℝ) ≤ 2*y+1)]
