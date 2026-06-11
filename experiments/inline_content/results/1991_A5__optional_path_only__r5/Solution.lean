import Mathlib

open scoped Real

noncomputable def putnam_1991_a5_solution : ℝ := 1 / 3

theorem putnam_1991_a5 :
    IsGreatest
      {t : ℝ | ∃ y ∈ Set.Icc (0 : ℝ) 1,
        (∫ x in (0 : ℝ)..y, Real.sqrt (x ^ 4 + (y - y ^ 2) ^ 2)) = t}
      putnam_1991_a5_solution := by
  constructor
  · -- membership: y = 1 gives value 1/3
    refine ⟨1, ⟨by norm_num, le_refl 1⟩, ?_⟩
    have h : (fun x : ℝ => Real.sqrt (x ^ 4 + ((1 : ℝ) - 1 ^ 2) ^ 2))
        = fun x : ℝ => x ^ 2 := by
      funext x
      have h0 : ((1 : ℝ) - 1 ^ 2) ^ 2 = 0 := by norm_num
      rw [h0, add_zero, show x ^ 4 = (x ^ 2) ^ 2 by ring, Real.sqrt_sq (sq_nonneg x)]
    show (∫ x in (0 : ℝ)..1, Real.sqrt (x ^ 4 + ((1 : ℝ) - 1 ^ 2) ^ 2)) = putnam_1991_a5_solution
    rw [h, integral_pow]
    norm_num [putnam_1991_a5_solution]
  · -- upper bound
    rintro t ⟨y, ⟨hy0, hy1⟩, rfl⟩
    set c := y - y ^ 2 with hc
    have hcnn : 0 ≤ c := by
      rw [hc]; nlinarith [mul_nonneg hy0 (show (0 : ℝ) ≤ 1 - y by linarith)]
    have cont1 : Continuous (fun x : ℝ => Real.sqrt (x ^ 4 + c ^ 2)) := by fun_prop
    have cont2 : Continuous (fun x : ℝ => x ^ 2 + c) := by fun_prop
    have hbound : (∫ x in (0 : ℝ)..y, Real.sqrt (x ^ 4 + c ^ 2))
        ≤ ∫ x in (0 : ℝ)..y, (x ^ 2 + c) := by
      apply intervalIntegral.integral_mono_on hy0 (cont1.intervalIntegrable 0 y)
        (cont2.intervalIntegrable 0 y)
      · intro x _
        rw [show x ^ 2 + c = Real.sqrt ((x ^ 2 + c) ^ 2)
              from (Real.sqrt_sq (add_nonneg (sq_nonneg x) hcnn)).symm]
        apply Real.sqrt_le_sqrt
        nlinarith [mul_nonneg (sq_nonneg x) hcnn]
    have hrhs : (∫ x in (0 : ℝ)..y, (x ^ 2 + c)) = y ^ 3 / 3 + c * y := by
      rw [intervalIntegral.integral_add
            ((continuous_pow 2).intervalIntegrable 0 y) intervalIntegrable_const,
          integral_pow, intervalIntegral.integral_const]
      simp
      ring
    have hfinal : y ^ 3 / 3 + c * y ≤ 1 / 3 := by
      rw [hc]
      nlinarith [mul_nonneg (sq_nonneg (y - 1)) (show (0 : ℝ) ≤ 2 * y + 1 by linarith)]
    show (∫ x in (0 : ℝ)..y, Real.sqrt (x ^ 4 + c ^ 2)) ≤ putnam_1991_a5_solution
    rw [putnam_1991_a5_solution]
    rw [hrhs] at hbound
    linarith
