import Mathlib

open MeasureTheory intervalIntegral Real Set

noncomputable def putnam_1991_a5_solution : ℝ := 1/3

theorem putnam_1991_a5 :
    IsGreatest
      ((fun y : ℝ => ∫ x in (0:ℝ)..y, Real.sqrt (x^4 + (y - y^2)^2)) '' Set.Icc 0 1)
      putnam_1991_a5_solution := by
  refine ⟨⟨1, ⟨zero_le_one, le_refl 1⟩, ?_⟩, ?_⟩
  · -- Membership: at y=1, integral equals 1/3
    show (∫ x in (0:ℝ)..1, Real.sqrt (x^4 + (1 - 1^2)^2)) = putnam_1991_a5_solution
    have hcong : ∀ x ∈ uIcc (0:ℝ) 1, Real.sqrt (x^4 + (1 - 1^2)^2) = x^2 := by
      intros x _
      have : (1:ℝ) - 1^2 = 0 := by ring
      rw [this]
      simp
      rw [show x^4 = (x^2)^2 by ring]
      exact Real.sqrt_sq (sq_nonneg x)
    rw [intervalIntegral.integral_congr hcong]
    rw [integral_pow]
    simp [putnam_1991_a5_solution]
    ring
  · -- Upper bound
    rintro I ⟨y, ⟨hy0, hy1⟩, rfl⟩
    show (∫ x in (0:ℝ)..y, Real.sqrt (x^4 + (y - y^2)^2)) ≤ putnam_1991_a5_solution
    have hyy : (0:ℝ) ≤ y - y^2 := by nlinarith
    -- Bound the integrand
    have hbound : ∀ x ∈ Icc (0:ℝ) y, Real.sqrt (x^4 + (y - y^2)^2) ≤ x^2 + (y - y^2) := by
      intros x _
      have hsum : (0:ℝ) ≤ x^2 + (y - y^2) := add_nonneg (sq_nonneg x) hyy
      rw [show x^2 + (y - y^2) = Real.sqrt ((x^2 + (y - y^2))^2) from
            (Real.sqrt_sq hsum).symm]
      apply Real.sqrt_le_sqrt
      nlinarith [sq_nonneg x, hyy]
    -- Integrability
    have hcont1 : Continuous (fun x : ℝ => Real.sqrt (x^4 + (y - y^2)^2)) := by
      apply Real.continuous_sqrt.comp
      continuity
    have hcont2 : Continuous (fun x : ℝ => x^2 + (y - y^2)) := by continuity
    have hint1 : IntervalIntegrable (fun x : ℝ => Real.sqrt (x^4 + (y - y^2)^2))
                  MeasureTheory.volume 0 y := hcont1.intervalIntegrable _ _
    have hint2 : IntervalIntegrable (fun x : ℝ => x^2 + (y - y^2))
                  MeasureTheory.volume 0 y := hcont2.intervalIntegrable _ _
    have h1 : (∫ x in (0:ℝ)..y, Real.sqrt (x^4 + (y - y^2)^2))
              ≤ ∫ x in (0:ℝ)..y, (x^2 + (y - y^2)) :=
      intervalIntegral.integral_mono_on hy0 hint1 hint2 hbound
    have h2 : (∫ x in (0:ℝ)..y, (x^2 + (y - y^2)))
              = y^3/3 + y^2 - y^3 := by
      rw [intervalIntegral.integral_add]
      · rw [integral_pow, intervalIntegral.integral_const]
        simp
        ring
      · exact (continuous_pow 2).intervalIntegrable _ _
      · exact continuous_const.intervalIntegrable _ _
    rw [h2] at h1
    -- Now show y^3/3 + y^2 - y^3 ≤ 1/3, i.e., (1-y)^2(1+2y) ≥ 0
    have h3 : y^3/3 + y^2 - y^3 ≤ (1:ℝ)/3 := by nlinarith [sq_nonneg (1-y), sq_nonneg y]
    show (∫ x in (0:ℝ)..y, Real.sqrt (x^4 + (y - y^2)^2)) ≤ putnam_1991_a5_solution
    unfold putnam_1991_a5_solution
    linarith
