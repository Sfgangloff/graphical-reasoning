import Mathlib

open MeasureTheory intervalIntegral

noncomputable def putnam_1991_a5_solution : ℝ := 1/3

theorem putnam_1991_a5 :
    IsGreatest {z : ℝ | ∃ y : ℝ, 0 ≤ y ∧ y ≤ 1 ∧
      z = ∫ x in (0:ℝ)..y, Real.sqrt (x^4 + (y - y^2)^2)} putnam_1991_a5_solution := by
  constructor
  · -- membership: achieved at y = 1
    refine ⟨1, by norm_num, le_refl 1, ?_⟩
    have hsq : ∀ x : ℝ, Real.sqrt (x^4 + ((1:ℝ) - 1^2)^2) = x^2 := by
      intro x
      have : (x^4 + ((1:ℝ) - 1^2)^2) = (x^2)^2 := by ring
      rw [this, Real.sqrt_sq (sq_nonneg x)]
    rw [putnam_1991_a5_solution]
    rw [intervalIntegral.integral_congr (g := fun x => x^2)]
    · simp [integral_pow]; norm_num
    · intro x _
      simpa using hsq x
  · -- upper bound
    rintro z ⟨y, hy0, hy1, rfl⟩
    have hyy : (0:ℝ) ≤ y - y^2 := by nlinarith
    have hbound : (∫ x in (0:ℝ)..y, Real.sqrt (x^4 + (y - y^2)^2))
        ≤ ∫ x in (0:ℝ)..y, (x^2 + (y - y^2)) := by
      apply intervalIntegral.integral_mono_on hy0
      · apply Continuous.intervalIntegrable; fun_prop
      · apply Continuous.intervalIntegrable; fun_prop
      · intro x hx
        have hb : (0:ℝ) ≤ x^2 + (y - y^2) := add_nonneg (sq_nonneg x) hyy
        calc Real.sqrt (x^4 + (y - y^2)^2)
            ≤ Real.sqrt ((x^2 + (y - y^2))^2) :=
              Real.sqrt_le_sqrt (by nlinarith [sq_nonneg x, hyy])
          _ = x^2 + (y - y^2) := Real.sqrt_sq hb
    rw [putnam_1991_a5_solution]
    refine le_trans hbound ?_
    rw [intervalIntegral.integral_add (by apply Continuous.intervalIntegrable; fun_prop)
        (by apply Continuous.intervalIntegrable; fun_prop)]
    rw [integral_pow, intervalIntegral.integral_const]
    simp only [smul_eq_mul, sub_zero]
    nlinarith [sq_nonneg (y - 1), hy0, hy1]
