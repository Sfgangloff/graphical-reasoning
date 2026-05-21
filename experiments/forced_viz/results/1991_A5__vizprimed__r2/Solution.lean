import Mathlib

open scoped Real
open MeasureTheory intervalIntegral

noncomputable def putnam_1991_a5_solution : ℝ := 1/3

theorem putnam_1991_a5 :
    IsGreatest
      {t : ℝ | ∃ y ∈ Set.Icc (0:ℝ) 1,
        (∫ x in (0:ℝ)..y, Real.sqrt (x^4 + (y - y^2)^2)) = t}
      putnam_1991_a5_solution := by
  constructor
  · -- 1/3 is attained at y = 1
    refine ⟨1, ⟨by norm_num, by norm_num⟩, ?_⟩
    have hsq : ∀ x : ℝ, Real.sqrt (x^4 + ((1:ℝ) - 1^2)^2) = x^2 := by
      intro x
      have hxx : x^4 + ((1:ℝ) - 1^2)^2 = (x^2)^2 := by ring
      rw [hxx, Real.sqrt_sq (sq_nonneg x)]
    simp_rw [hsq]
    rw [integral_pow]
    norm_num [putnam_1991_a5_solution]
  · -- 1/3 is an upper bound
    rintro t ⟨y, ⟨hy0, hy1⟩, rfl⟩
    have hyy : 0 ≤ y - y^2 := by nlinarith
    have hcont1 : Continuous (fun x : ℝ => Real.sqrt (x^4 + (y - y^2)^2)) := by
      fun_prop
    have hcont2 : Continuous (fun x : ℝ => x^2 + (y - y^2)) := by fun_prop
    have hi1 : IntervalIntegrable (fun x : ℝ => Real.sqrt (x^4 + (y - y^2)^2))
        volume 0 y := hcont1.intervalIntegrable 0 y
    have hi2 : IntervalIntegrable (fun x : ℝ => x^2 + (y - y^2))
        volume 0 y := hcont2.intervalIntegrable 0 y
    have hle : ∀ x ∈ Set.Icc (0:ℝ) y,
        Real.sqrt (x^4 + (y - y^2)^2) ≤ x^2 + (y - y^2) := by
      intro x _
      have hb : x^4 + (y - y^2)^2 ≤ (x^2 + (y - y^2))^2 := by
        nlinarith [mul_nonneg (sq_nonneg x) hyy]
      calc Real.sqrt (x^4 + (y - y^2)^2)
          ≤ Real.sqrt ((x^2 + (y - y^2))^2) := Real.sqrt_le_sqrt hb
        _ = x^2 + (y - y^2) := Real.sqrt_sq (add_nonneg (sq_nonneg x) hyy)
    calc (∫ x in (0:ℝ)..y, Real.sqrt (x^4 + (y - y^2)^2))
        ≤ ∫ x in (0:ℝ)..y, (x^2 + (y - y^2)) :=
          intervalIntegral.integral_mono_on hy0 hi1 hi2 hle
      _ = y^3/3 + (y - y^2) * y := by
          have hia : IntervalIntegrable (fun x : ℝ => x^2) volume 0 y :=
            (continuous_pow 2).intervalIntegrable 0 y
          have hib : IntervalIntegrable (fun _ : ℝ => y - y^2) volume 0 y :=
            intervalIntegral.intervalIntegrable_const
          rw [intervalIntegral.integral_add hia hib, integral_pow,
            intervalIntegral.integral_const]
          simp only [smul_eq_mul]
          push_cast
          ring
      _ ≤ putnam_1991_a5_solution := by
          unfold putnam_1991_a5_solution
          nlinarith [sq_nonneg (y - 1), hy0, hy1]
