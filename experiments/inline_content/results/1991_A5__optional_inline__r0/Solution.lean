import Mathlib

noncomputable def putnam_1991_a5_solution : ℝ := 1 / 3

theorem putnam_1991_a5
    (f : ℝ → ℝ)
    (hf : f = fun y => ∫ x in (0:ℝ)..y, Real.sqrt (x ^ 4 + (y - y ^ 2) ^ 2)) :
    IsGreatest {t : ℝ | ∃ y ∈ Set.Icc (0:ℝ) 1, f y = t} putnam_1991_a5_solution := by
  constructor
  · -- membership: y = 1 gives 1/3
    refine ⟨1, ⟨by norm_num, le_refl _⟩, ?_⟩
    rw [hf]
    simp only
    have h1 : (∫ x in (0:ℝ)..1, Real.sqrt (x ^ 4 + ((1:ℝ) - 1 ^ 2) ^ 2))
        = ∫ x in (0:ℝ)..1, x ^ 2 := by
      apply intervalIntegral.integral_congr
      intro x hx
      simp only
      rw [show ((1:ℝ) - 1 ^ 2) ^ 2 = 0 by norm_num, add_zero,
        show x ^ 4 = (x ^ 2) ^ 2 by ring, Real.sqrt_sq (by positivity)]
    rw [h1, integral_pow]
    norm_num [putnam_1991_a5_solution]
  · -- upper bound
    rintro t ⟨y, hy, rfl⟩
    obtain ⟨hy0, hy1⟩ := hy
    rw [hf]
    simp only
    have hcont : Continuous (fun x : ℝ => Real.sqrt (x ^ 4 + (y - y ^ 2) ^ 2)) := by
      fun_prop
    have hbound : (∫ x in (0:ℝ)..y, Real.sqrt (x ^ 4 + (y - y ^ 2) ^ 2))
        ≤ ∫ x in (0:ℝ)..y, (x ^ 2 + (y - y ^ 2)) := by
      apply intervalIntegral.integral_mono_on hy0
      · exact hcont.intervalIntegrable _ _
      · exact (by fun_prop : Continuous (fun x : ℝ => x ^ 2 + (y - y ^ 2))).intervalIntegrable _ _
      · intro x hx
        have hc : (0:ℝ) ≤ y - y ^ 2 := by nlinarith
        calc Real.sqrt (x ^ 4 + (y - y ^ 2) ^ 2)
            ≤ Real.sqrt ((x ^ 2 + (y - y ^ 2)) ^ 2) := by
              apply Real.sqrt_le_sqrt
              nlinarith [sq_nonneg x, mul_nonneg (sq_nonneg x) hc]
          _ = x ^ 2 + (y - y ^ 2) := Real.sqrt_sq (add_nonneg (sq_nonneg x) hc)
    refine le_trans hbound ?_
    have hival : (∫ x in (0:ℝ)..y, (x ^ 2 + (y - y ^ 2)))
        = y ^ 3 / 3 + y * (y - y ^ 2) := by
      rw [intervalIntegral.integral_add
            ((by fun_prop : Continuous (fun x : ℝ => x ^ 2)).intervalIntegrable _ _)
            (intervalIntegrable_const)]
      rw [integral_pow, intervalIntegral.integral_const]
      simp
      ring
    rw [hival]
    show y ^ 3 / 3 + y * (y - y ^ 2) ≤ putnam_1991_a5_solution
    rw [putnam_1991_a5_solution]
    nlinarith [sq_nonneg (y - 1), sq_nonneg y, mul_nonneg hy0 (sub_nonneg.mpr hy1)]
