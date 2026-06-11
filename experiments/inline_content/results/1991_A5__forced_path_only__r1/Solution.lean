import Mathlib

open intervalIntegral MeasureTheory

noncomputable def putnam_1991_a5_solution : ℝ := 1/3

theorem putnam_1991_a5 :
    IsGreatest {t : ℝ | ∃ y : ℝ, 0 ≤ y ∧ y ≤ 1 ∧
      (∫ x in (0:ℝ)..y, Real.sqrt (x ^ 4 + (y - y ^ 2) ^ 2)) = t}
      putnam_1991_a5_solution := by
  constructor
  · -- the value 1/3 is attained at y = 1
    refine ⟨1, by norm_num, by norm_num, ?_⟩
    have heq : (∫ x in (0:ℝ)..1, Real.sqrt (x ^ 4 + ((1:ℝ) - 1 ^ 2) ^ 2))
        = ∫ x in (0:ℝ)..1, x ^ 2 := by
      apply intervalIntegral.integral_congr
      intro x _
      show Real.sqrt (x ^ 4 + ((1:ℝ) - 1 ^ 2) ^ 2) = x ^ 2
      have h1 : x ^ 4 + ((1:ℝ) - 1 ^ 2) ^ 2 = (x ^ 2) ^ 2 := by ring
      rw [h1, Real.sqrt_sq (sq_nonneg x)]
    rw [heq, integral_pow]
    simp only [putnam_1991_a5_solution]
    norm_num
  · -- 1/3 is an upper bound
    rintro t ⟨y, hy0, hy1, rfl⟩
    set c := y - y ^ 2 with hc
    have hcnn : 0 ≤ c := by
      rw [hc]; nlinarith [mul_nonneg hy0 (by linarith : (0:ℝ) ≤ 1 - y)]
    have hf : IntervalIntegrable (fun x => Real.sqrt (x ^ 4 + c ^ 2)) volume 0 y := by
      apply Continuous.intervalIntegrable; fun_prop
    have hg : IntervalIntegrable (fun x => x ^ 2 + c) volume 0 y := by
      apply Continuous.intervalIntegrable; fun_prop
    have hmono : (∫ x in (0:ℝ)..y, Real.sqrt (x ^ 4 + c ^ 2))
        ≤ ∫ x in (0:ℝ)..y, (x ^ 2 + c) := by
      apply intervalIntegral.integral_mono_on hy0 hf hg
      intro x _
      rw [show x ^ 2 + c = Real.sqrt ((x ^ 2 + c) ^ 2) from
        (Real.sqrt_sq (add_nonneg (sq_nonneg x) hcnn)).symm]
      apply Real.sqrt_le_sqrt
      nlinarith [mul_nonneg hcnn (sq_nonneg x)]
    have hcalc : (∫ x in (0:ℝ)..y, (x ^ 2 + c)) = y ^ 3 / 3 + c * y := by
      have hsq : IntervalIntegrable (fun x : ℝ => x ^ 2) volume 0 y :=
        (show Continuous (fun x : ℝ => x ^ 2) by fun_prop).intervalIntegrable 0 y
      rw [intervalIntegral.integral_add hsq _root_.intervalIntegrable_const, integral_pow,
        intervalIntegral.integral_const]
      simp
      ring
    have hbound : (∫ x in (0:ℝ)..y, Real.sqrt (x ^ 4 + c ^ 2)) ≤ y ^ 3 / 3 + c * y := by
      rw [← hcalc]; exact hmono
    simp only [putnam_1991_a5_solution]
    calc (∫ x in (0:ℝ)..y, Real.sqrt (x ^ 4 + c ^ 2)) ≤ y ^ 3 / 3 + c * y := hbound
      _ ≤ 1 / 3 := by rw [hc]; nlinarith [sq_nonneg (y - 1), hy0, hy1]
