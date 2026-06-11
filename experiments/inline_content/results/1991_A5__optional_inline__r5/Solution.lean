import Mathlib

open scoped Real

noncomputable def putnam_1991_a5_solution : ℝ := 1 / 3

theorem putnam_1991_a5
    (f : ℝ → ℝ)
    (hf : f = fun y => ∫ x in (0:ℝ)..y, Real.sqrt (x ^ 4 + (y - y ^ 2) ^ 2)) :
    IsGreatest {y_0 | ∃ y ∈ Set.Icc (0 : ℝ) 1, f y = y_0} putnam_1991_a5_solution := by
  subst hf
  constructor
  · -- membership: value 1/3 attained at y = 1
    refine ⟨1, ⟨by norm_num, le_refl _⟩, ?_⟩
    show (∫ x in (0:ℝ)..1, Real.sqrt (x ^ 4 + ((1:ℝ) - 1 ^ 2) ^ 2)) = putnam_1991_a5_solution
    have hcong : ∀ x : ℝ, Real.sqrt (x ^ 4 + ((1:ℝ) - 1 ^ 2) ^ 2) = x ^ 2 := by
      intro x
      rw [show ((1:ℝ) - 1 ^ 2) ^ 2 = 0 by norm_num, add_zero,
          show x ^ 4 = (x ^ 2) ^ 2 by ring, Real.sqrt_sq (sq_nonneg x)]
    rw [intervalIntegral.integral_congr (g := fun x => x ^ 2) (fun x _ => hcong x),
        integral_pow]
    norm_num [putnam_1991_a5_solution]
  · -- upper bound
    rintro y_0 ⟨y, hy, rfl⟩
    obtain ⟨hy0, hy1⟩ := hy
    show (∫ x in (0:ℝ)..y, Real.sqrt (x ^ 4 + (y - y ^ 2) ^ 2)) ≤ putnam_1991_a5_solution
    have hb : 0 ≤ y - y ^ 2 := by nlinarith
    have key : (∫ x in (0:ℝ)..y, Real.sqrt (x ^ 4 + (y - y ^ 2) ^ 2))
             ≤ ∫ x in (0:ℝ)..y, (x ^ 2 + (y - y ^ 2)) := by
      apply intervalIntegral.integral_mono_on hy0
      · exact (by fun_prop : Continuous fun x : ℝ => Real.sqrt (x ^ 4 + (y - y ^ 2) ^ 2)).intervalIntegrable _ _
      · exact (by fun_prop : Continuous fun x : ℝ => x ^ 2 + (y - y ^ 2)).intervalIntegrable _ _
      · intro x _
        rw [show x ^ 4 = (x ^ 2) ^ 2 by ring]
        calc Real.sqrt ((x ^ 2) ^ 2 + (y - y ^ 2) ^ 2)
            ≤ Real.sqrt ((x ^ 2 + (y - y ^ 2)) ^ 2) := by
              apply Real.sqrt_le_sqrt
              nlinarith [mul_nonneg (sq_nonneg x) hb]
          _ = x ^ 2 + (y - y ^ 2) := Real.sqrt_sq (add_nonneg (sq_nonneg x) hb)
    have i1 : IntervalIntegrable (fun x : ℝ => x ^ 2) MeasureTheory.volume 0 y :=
      (continuous_pow 2).intervalIntegrable _ _
    have i2 : IntervalIntegrable (fun _ : ℝ => y - y ^ 2) MeasureTheory.volume 0 y :=
      intervalIntegrable_const
    have comp : (∫ x in (0:ℝ)..y, (x ^ 2 + (y - y ^ 2))) = y ^ 3 / 3 + (y - y ^ 2) * y := by
      rw [intervalIntegral.integral_add i1 i2, integral_pow, intervalIntegral.integral_const]
      simp only [smul_eq_mul]
      ring
    rw [comp] at key
    have final : y ^ 3 / 3 + (y - y ^ 2) * y ≤ putnam_1991_a5_solution := by
      unfold putnam_1991_a5_solution
      nlinarith [sq_nonneg (1 - y), sq_nonneg y, mul_nonneg (sq_nonneg (1 - y)) hy0]
    linarith
