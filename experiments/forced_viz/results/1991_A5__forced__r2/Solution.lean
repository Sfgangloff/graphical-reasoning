import Mathlib

open Real

noncomputable def putnam_1991_a5_solution : ℝ := 1 / 3

theorem putnam_1991_a5 :
    IsGreatest
      {t : ℝ | ∃ y ∈ Set.Icc (0 : ℝ) 1,
        t = ∫ x in (0 : ℝ)..y, Real.sqrt (x ^ 4 + (y - y ^ 2) ^ 2)}
      putnam_1991_a5_solution := by
  constructor
  · -- The value 1/3 is attained at y = 1.
    refine ⟨1, ?_, ?_⟩
    · exact Set.mem_Icc.mpr ⟨by norm_num, by norm_num⟩
    · have hcongr : ∀ x ∈ Set.uIcc (0 : ℝ) 1,
          Real.sqrt (x ^ 4 + ((1 : ℝ) - 1 ^ 2) ^ 2) = x ^ 2 := by
        intro x _
        have h1 : ((1 : ℝ) - 1 ^ 2) ^ 2 = 0 := by norm_num
        rw [h1, add_zero, show x ^ 4 = (x ^ 2) ^ 2 by ring,
          Real.sqrt_sq (by positivity)]
      rw [intervalIntegral.integral_congr hcongr, integral_pow]
      norm_num [putnam_1991_a5_solution]
  · -- 1/3 is an upper bound.
    rintro t ⟨y, hymem, rfl⟩
    rw [Set.mem_Icc] at hymem
    obtain ⟨hy0, hy1⟩ := hymem
    set c : ℝ := y - y ^ 2 with hc
    have hcnn : 0 ≤ c := by rw [hc]; nlinarith
    have hcont1 : Continuous (fun x : ℝ => Real.sqrt (x ^ 4 + c ^ 2)) := by
      fun_prop
    have hcont2 : Continuous (fun x : ℝ => x ^ 2 + c) := by fun_prop
    have hle : (∫ x in (0 : ℝ)..y, Real.sqrt (x ^ 4 + c ^ 2))
        ≤ ∫ x in (0 : ℝ)..y, (x ^ 2 + c) := by
      apply intervalIntegral.integral_mono_on hy0
      · exact hcont1.intervalIntegrable _ _
      · exact hcont2.intervalIntegrable _ _
      · intro x _
        have hpos : (0 : ℝ) ≤ x ^ 2 + c := by positivity
        rw [show x ^ 2 + c = Real.sqrt ((x ^ 2 + c) ^ 2) from
          (Real.sqrt_sq hpos).symm]
        apply Real.sqrt_le_sqrt
        nlinarith [sq_nonneg x, hcnn, sq_nonneg (x ^ 2)]
    have hi1 : IntervalIntegrable (fun x : ℝ => x ^ 2) MeasureTheory.volume 0 y :=
      (continuous_pow 2).intervalIntegrable _ _
    have hi2 : IntervalIntegrable (fun _ : ℝ => c) MeasureTheory.volume 0 y :=
      intervalIntegrable_const
    have hval : (∫ x in (0 : ℝ)..y, (x ^ 2 + c)) = y ^ 3 / 3 + c * y := by
      rw [intervalIntegral.integral_add hi1 hi2, integral_pow,
        intervalIntegral.integral_const]
      simp [smul_eq_mul]
      ring
    have hfinal : (∫ x in (0 : ℝ)..y, Real.sqrt (x ^ 4 + c ^ 2)) ≤ 1 / 3 := by
      calc (∫ x in (0 : ℝ)..y, Real.sqrt (x ^ 4 + c ^ 2))
          ≤ ∫ x in (0 : ℝ)..y, (x ^ 2 + c) := hle
        _ = y ^ 3 / 3 + c * y := hval
        _ ≤ 1 / 3 := by
            rw [hc]
            nlinarith [mul_nonneg (sq_nonneg (y - 1)) (by linarith : (0 : ℝ) ≤ 2 * y + 1)]
    simpa [putnam_1991_a5_solution] using hfinal
