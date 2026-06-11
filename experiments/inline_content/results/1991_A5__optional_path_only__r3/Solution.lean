import Mathlib

open Set MeasureTheory intervalIntegral

noncomputable def putnam_1991_a5_solution : ℝ := 1 / 3

theorem putnam_1991_a5 :
    IsGreatest {t : ℝ | ∃ y ∈ Set.Icc (0:ℝ) 1,
      t = ∫ x in (0:ℝ)..y, Real.sqrt (x ^ 4 + (y - y ^ 2) ^ 2)} putnam_1991_a5_solution := by
  constructor
  · -- membership: y = 1 gives 1/3
    refine ⟨1, ⟨by norm_num, le_refl _⟩, ?_⟩
    have hcongr : (∫ x in (0:ℝ)..1, Real.sqrt (x ^ 4 + ((1:ℝ) - 1 ^ 2) ^ 2))
        = ∫ x in (0:ℝ)..1, x ^ 2 := by
      apply intervalIntegral.integral_congr
      intro x hx
      simp only [Set.uIcc_of_le (by norm_num : (0:ℝ) ≤ 1)] at hx
      have hx0 : (0:ℝ) ≤ x := hx.1
      show Real.sqrt (x ^ 4 + ((1:ℝ) - 1 ^ 2) ^ 2) = x ^ 2
      have : x ^ 4 + ((1:ℝ) - 1 ^ 2) ^ 2 = (x ^ 2) ^ 2 := by ring
      rw [this, Real.sqrt_sq (by positivity)]
    rw [putnam_1991_a5_solution, hcongr, integral_pow]
    norm_num
  · -- upper bound
    rintro b ⟨y, ⟨hy0, hy1⟩, rfl⟩
    have hyy : 0 ≤ y - y ^ 2 := by nlinarith
    have hsqf : Continuous (fun x : ℝ => Real.sqrt (x ^ 4 + (y - y ^ 2) ^ 2)) := by fun_prop
    have hgf : Continuous (fun x : ℝ => x ^ 2 + (y - y ^ 2)) := by fun_prop
    have key : (∫ x in (0:ℝ)..y, Real.sqrt (x ^ 4 + (y - y ^ 2) ^ 2))
        ≤ ∫ x in (0:ℝ)..y, (x ^ 2 + (y - y ^ 2)) := by
      apply intervalIntegral.integral_mono_on hy0
        (hsqf.intervalIntegrable _ _) (hgf.intervalIntegrable _ _)
      intro x hx
      have hbound : x ^ 4 + (y - y ^ 2) ^ 2 ≤ (x ^ 2 + (y - y ^ 2)) ^ 2 := by
        nlinarith [mul_nonneg (sq_nonneg x) hyy]
      calc Real.sqrt (x ^ 4 + (y - y ^ 2) ^ 2)
          ≤ Real.sqrt ((x ^ 2 + (y - y ^ 2)) ^ 2) := Real.sqrt_le_sqrt hbound
        _ = x ^ 2 + (y - y ^ 2) := Real.sqrt_sq (add_nonneg (sq_nonneg x) hyy)
    have e1 : (∫ x in (0:ℝ)..y, x ^ 2) = y ^ 3 / 3 := by
      rw [integral_pow]; norm_num
    have hsum : (∫ x in (0:ℝ)..y, (x ^ 2 + (y - y ^ 2)))
        = y ^ 3 / 3 + (y - y ^ 2) * y := by
      rw [intervalIntegral.integral_add ((continuous_pow 2).intervalIntegrable _ _)
        (continuous_const.intervalIntegrable _ _), e1, intervalIntegral.integral_const]
      simp; ring
    rw [putnam_1991_a5_solution]
    calc (∫ x in (0:ℝ)..y, Real.sqrt (x ^ 4 + (y - y ^ 2) ^ 2))
        ≤ ∫ x in (0:ℝ)..y, (x ^ 2 + (y - y ^ 2)) := key
      _ = y ^ 3 / 3 + (y - y ^ 2) * y := hsum
      _ ≤ 1 / 3 := by nlinarith [mul_nonneg (sq_nonneg (y - 1)) (by linarith : (0:ℝ) ≤ 2 * y + 1)]
