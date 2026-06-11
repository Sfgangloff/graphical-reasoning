import Mathlib

open Real

noncomputable abbrev putnam_1991_a5_solution : ℝ := 1/3

theorem putnam_1991_a5 :
    IsGreatest {t : ℝ | ∃ y ∈ Set.Icc (0:ℝ) 1,
      t = ∫ x in (0:ℝ)..y, Real.sqrt (x^4 + (y - y^2)^2)} putnam_1991_a5_solution := by
  constructor
  · -- membership: y = 1 gives 1/3
    refine ⟨1, ⟨by norm_num, le_refl _⟩, ?_⟩
    have hfun : ∀ x ∈ Set.uIcc (0:ℝ) 1, Real.sqrt (x^4 + ((1:ℝ) - 1^2)^2) = x^2 := by
      intro x _
      have h0 : ((1:ℝ) - 1^2) = 0 := by norm_num
      rw [h0]
      rw [show x^4 + (0:ℝ)^2 = (x^2)^2 by ring]
      exact Real.sqrt_sq (sq_nonneg x)
    rw [intervalIntegral.integral_congr hfun, integral_pow]
    norm_num
  · rintro t ⟨y, ⟨hy0, hy1⟩, rfl⟩
    have hc : (0:ℝ) ≤ y - y^2 := by nlinarith
    have hbound : ∀ x ∈ Set.Icc (0:ℝ) y,
        Real.sqrt (x^4 + (y - y^2)^2) ≤ x^2 + (y - y^2) := by
      intro x _
      rw [show x^4 = (x^2)^2 by ring]
      have h1 : Real.sqrt ((x^2)^2 + (y - y^2)^2) ≤ Real.sqrt ((x^2 + (y - y^2))^2) := by
        apply Real.sqrt_le_sqrt
        nlinarith [mul_nonneg (sq_nonneg x) hc]
      rwa [Real.sqrt_sq (by positivity)] at h1
    have hint1 : IntervalIntegrable (fun x => Real.sqrt (x^4 + (y - y^2)^2))
        MeasureTheory.volume 0 y := by
      apply Continuous.intervalIntegrable; fun_prop
    have hint2 : IntervalIntegrable (fun x => x^2 + (y - y^2))
        MeasureTheory.volume 0 y := by
      apply Continuous.intervalIntegrable; fun_prop
    calc ∫ x in (0:ℝ)..y, Real.sqrt (x^4 + (y - y^2)^2)
        ≤ ∫ x in (0:ℝ)..y, (x^2 + (y - y^2)) :=
          intervalIntegral.integral_mono_on hy0 hint1 hint2 hbound
      _ = y^3/3 + (y - y^2) * y := by
          rw [intervalIntegral.integral_add (by apply Continuous.intervalIntegrable; fun_prop)
            (by apply Continuous.intervalIntegrable; fun_prop),
            integral_pow, intervalIntegral.integral_const]
          simp; ring
      _ ≤ 1/3 := by nlinarith [sq_nonneg (y - 1)]
