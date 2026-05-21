import Mathlib

open MeasureTheory

noncomputable def putnam_1991_a5_solution : ℝ := 1/3

theorem putnam_1991_a5 :
    IsGreatest
      {z : ℝ | ∃ y ∈ Set.Icc (0:ℝ) 1,
        z = ∫ x in (0:ℝ)..y, Real.sqrt (x ^ 4 + (y - y ^ 2) ^ 2)}
      putnam_1991_a5_solution := by
  constructor
  · -- The value 1/3 is attained at y = 1.
    refine ⟨1, Set.mem_Icc.mpr ⟨by norm_num, by norm_num⟩, ?_⟩
    have h : Set.EqOn (fun x : ℝ => Real.sqrt (x ^ 4 + ((1:ℝ) - 1 ^ 2) ^ 2))
        (fun x : ℝ => x ^ 2) (Set.uIcc 0 1) := by
      intro x _
      simp only
      have h0 : ((1:ℝ) - 1 ^ 2) ^ 2 = 0 := by norm_num
      rw [h0, add_zero, show x ^ 4 = (x ^ 2) ^ 2 by ring]
      exact Real.sqrt_sq (sq_nonneg x)
    rw [intervalIntegral.integral_congr h, integral_pow]
    norm_num [putnam_1991_a5_solution]
  · -- 1/3 is an upper bound.
    rintro z ⟨y, hymem, rfl⟩
    obtain ⟨hy0, hy1⟩ := Set.mem_Icc.mp hymem
    have hyle : (0:ℝ) ≤ y - y ^ 2 := by nlinarith [mul_nonneg hy0 (sub_nonneg.mpr hy1)]
    have hbound : ∀ x : ℝ,
        Real.sqrt (x ^ 4 + (y - y ^ 2) ^ 2) ≤ x ^ 2 + (y - y ^ 2) := by
      intro x
      have hstep : Real.sqrt (x ^ 4 + (y - y ^ 2) ^ 2)
          ≤ Real.sqrt ((x ^ 2 + (y - y ^ 2)) ^ 2) := by
        apply Real.sqrt_le_sqrt
        nlinarith [mul_nonneg (sq_nonneg x) hyle]
      calc Real.sqrt (x ^ 4 + (y - y ^ 2) ^ 2)
          ≤ Real.sqrt ((x ^ 2 + (y - y ^ 2)) ^ 2) := hstep
        _ = x ^ 2 + (y - y ^ 2) := Real.sqrt_sq (add_nonneg (sq_nonneg x) hyle)
    have hcont : Continuous (fun x : ℝ => Real.sqrt (x ^ 4 + (y - y ^ 2) ^ 2)) := by
      fun_prop
    have hint1 : IntervalIntegrable
        (fun x : ℝ => Real.sqrt (x ^ 4 + (y - y ^ 2) ^ 2)) volume 0 y :=
      hcont.intervalIntegrable 0 y
    have hint2 : IntervalIntegrable
        (fun x : ℝ => x ^ 2 + (y - y ^ 2)) volume 0 y := by
      apply Continuous.intervalIntegrable
      fun_prop
    have hmono : (∫ x in (0:ℝ)..y, Real.sqrt (x ^ 4 + (y - y ^ 2) ^ 2))
        ≤ ∫ x in (0:ℝ)..y, (x ^ 2 + (y - y ^ 2)) := by
      apply intervalIntegral.integral_mono_on hy0 hint1 hint2
      intro x _
      exact hbound x
    have hval : (∫ x in (0:ℝ)..y, (x ^ 2 + (y - y ^ 2)))
        = y ^ 3 / 3 + (y - y ^ 2) * y := by
      rw [intervalIntegral.integral_add ((continuous_pow 2).intervalIntegrable 0 y)
        (continuous_const.intervalIntegrable 0 y),
        integral_pow, intervalIntegral.integral_const, smul_eq_mul]
      push_cast
      ring
    rw [hval] at hmono
    have hfinal : y ^ 3 / 3 + (y - y ^ 2) * y ≤ 1 / 3 := by
      nlinarith [mul_nonneg (sq_nonneg (y - 1)) (show (0:ℝ) ≤ 2 * y + 1 by linarith)]
    calc (∫ x in (0:ℝ)..y, Real.sqrt (x ^ 4 + (y - y ^ 2) ^ 2))
        ≤ y ^ 3 / 3 + (y - y ^ 2) * y := hmono
      _ ≤ 1 / 3 := hfinal
      _ = putnam_1991_a5_solution := by rw [putnam_1991_a5_solution]
