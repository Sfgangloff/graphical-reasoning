import Mathlib

open MeasureTheory

noncomputable def putnam_1991_a5_solution : ℝ := 1 / 3

theorem putnam_1991_a5 :
    IsGreatest {t : ℝ | ∃ y ∈ Set.Icc (0:ℝ) 1,
      t = ∫ x in (0:ℝ)..y, Real.sqrt (x ^ 4 + (y - y ^ 2) ^ 2)} putnam_1991_a5_solution := by
  constructor
  · -- membership: achieved at y = 1
    refine ⟨1, by norm_num [Set.mem_Icc], ?_⟩
    rw [putnam_1991_a5_solution]
    have hcongr : (∫ x in (0:ℝ)..1, Real.sqrt (x ^ 4 + ((1:ℝ) - 1 ^ 2) ^ 2))
        = ∫ x in (0:ℝ)..1, x ^ 2 := by
      apply intervalIntegral.integral_congr
      intro x _
      show Real.sqrt (x ^ 4 + ((1:ℝ) - 1 ^ 2) ^ 2) = x ^ 2
      rw [show ((1:ℝ) - 1 ^ 2) ^ 2 = 0 by norm_num, add_zero,
        show x ^ 4 = (x ^ 2) ^ 2 by ring, Real.sqrt_sq (sq_nonneg x)]
    rw [hcongr, integral_pow]
    norm_num
  · -- upper bound
    rintro t ⟨y, ⟨hy0, hy1⟩, rfl⟩
    rw [putnam_1991_a5_solution]
    have hc : (0:ℝ) ≤ y - y ^ 2 := by nlinarith [hy0, hy1]
    have hbound : ∀ x ∈ Set.Icc (0:ℝ) y,
        Real.sqrt (x ^ 4 + (y - y ^ 2) ^ 2) ≤ x ^ 2 + (y - y ^ 2) := by
      intro x _
      have h1 : (0:ℝ) ≤ x ^ 2 + (y - y ^ 2) := by positivity
      have h2 : Real.sqrt (x ^ 4 + (y - y ^ 2) ^ 2)
          ≤ Real.sqrt ((x ^ 2 + (y - y ^ 2)) ^ 2) := by
        apply Real.sqrt_le_sqrt
        nlinarith [mul_nonneg (sq_nonneg x) hc]
      rwa [Real.sqrt_sq h1] at h2
    have hint1 : IntervalIntegrable (fun x => Real.sqrt (x ^ 4 + (y - y ^ 2) ^ 2))
        volume 0 y := (by fun_prop : Continuous fun x : ℝ => Real.sqrt (x ^ 4 + (y - y ^ 2) ^ 2)).intervalIntegrable _ _
    have hint2 : IntervalIntegrable (fun x : ℝ => x ^ 2 + (y - y ^ 2))
        volume 0 y := (by fun_prop : Continuous fun x : ℝ => x ^ 2 + (y - y ^ 2)).intervalIntegrable _ _
    have hi1 : IntervalIntegrable (fun x : ℝ => x ^ 2) volume 0 y :=
      (by fun_prop : Continuous fun x : ℝ => x ^ 2).intervalIntegrable _ _
    have hmono : (∫ x in (0:ℝ)..y, Real.sqrt (x ^ 4 + (y - y ^ 2) ^ 2))
        ≤ ∫ x in (0:ℝ)..y, (x ^ 2 + (y - y ^ 2)) :=
      intervalIntegral.integral_mono_on hy0 hint1 hint2 hbound
    have hval : (∫ x in (0:ℝ)..y, (x ^ 2 + (y - y ^ 2)))
        = y ^ 3 / 3 + (y - y ^ 2) * y := by
      rw [intervalIntegral.integral_add hi1 (intervalIntegrable_const), integral_pow,
        intervalIntegral.integral_const]
      simp only [smul_eq_mul]
      ring
    calc (∫ x in (0:ℝ)..y, Real.sqrt (x ^ 4 + (y - y ^ 2) ^ 2))
        ≤ ∫ x in (0:ℝ)..y, (x ^ 2 + (y - y ^ 2)) := hmono
      _ = y ^ 3 / 3 + (y - y ^ 2) * y := hval
      _ ≤ 1 / 3 := by nlinarith [sq_nonneg (y - 1), mul_nonneg (sq_nonneg (y - 1)) hy0]
