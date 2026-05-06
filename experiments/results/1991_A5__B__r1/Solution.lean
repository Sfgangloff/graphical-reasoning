import Mathlib

open MeasureTheory Real intervalIntegral Set

noncomputable abbrev putnam_1991_a5_solution : ℝ := 1/3

theorem putnam_1991_a5 :
    IsGreatest
      {I : ℝ | ∃ y ∈ Set.Icc (0:ℝ) 1,
        I = ∫ x in (0:ℝ)..y, Real.sqrt (x^4 + (y - y^2)^2)}
      putnam_1991_a5_solution := by
  constructor
  · refine ⟨1, ⟨zero_le_one, le_refl 1⟩, ?_⟩
    have h1 : ∫ x in (0:ℝ)..1, Real.sqrt (x^4 + ((1:ℝ) - 1^2)^2)
            = ∫ x in (0:ℝ)..1, x^2 := by
      apply intervalIntegral.integral_congr
      intro x hx
      have hx0 : 0 ≤ x := by
        rw [Set.uIcc_of_le (zero_le_one : (0:ℝ) ≤ 1)] at hx
        exact hx.1
      simp only [one_pow, sub_self]
      rw [show ((0:ℝ))^2 = 0 by norm_num, add_zero]
      rw [show x^4 = (x^2)^2 by ring]
      exact Real.sqrt_sq (sq_nonneg x)
    rw [h1, integral_pow]
    norm_num
  · rintro I ⟨y, ⟨hy0, hy1⟩, hI⟩
    rw [hI]
    have hy2 : 0 ≤ y - y^2 := by nlinarith
    have step1 : ∀ x ∈ Set.uIcc (0:ℝ) y,
        Real.sqrt (x^4 + (y - y^2)^2) ≤ x^2 + (y - y^2) := by
      intro x _
      have hx2 : (0:ℝ) ≤ x^2 := sq_nonneg x
      have hxy2 : (0:ℝ) ≤ (y - y^2)^2 := sq_nonneg _
      have hsum : (0:ℝ) ≤ x^2 + (y - y^2) := by linarith
      have key : Real.sqrt (x^4 + (y - y^2)^2) ≤ x^2 + (y - y^2) := by
        rw [show (x^2 + (y - y^2)) = Real.sqrt ((x^2 + (y-y^2))^2) from
          (Real.sqrt_sq hsum).symm]
        apply Real.sqrt_le_sqrt
        have : (x^2 + (y - y^2))^2 - (x^4 + (y - y^2)^2) = 2 * x^2 * (y - y^2) := by ring
        nlinarith [hx2, hy2, mul_nonneg hx2 hy2]
      exact key
    have hint_sqrt : IntervalIntegrable
        (fun x => Real.sqrt (x^4 + (y - y^2)^2)) MeasureTheory.volume 0 y := by
      apply Continuous.intervalIntegrable
      continuity
    have hint_poly : IntervalIntegrable
        (fun x => x^2 + (y - y^2)) MeasureTheory.volume 0 y := by
      apply Continuous.intervalIntegrable
      continuity
    have step2 : ∫ x in (0:ℝ)..y, Real.sqrt (x^4 + (y - y^2)^2)
              ≤ ∫ x in (0:ℝ)..y, (x^2 + (y - y^2)) := by
      apply intervalIntegral.integral_mono_on hy0 hint_sqrt hint_poly
      intro x hx
      apply step1
      rw [Set.uIcc_of_le hy0]
      exact hx
    have step3 : ∫ x in (0:ℝ)..y, (x^2 + (y - y^2)) = y^3/3 + (y - y^2) * y := by
      rw [intervalIntegral.integral_add]
      · rw [integral_pow, intervalIntegral.integral_const]
        simp; ring
      · exact (continuous_pow 2).intervalIntegrable 0 y
      · exact continuous_const.intervalIntegrable 0 y
    have step4 : y^3/3 + (y - y^2) * y ≤ 1/3 := by
      nlinarith [sq_nonneg (y-1), sq_nonneg y, hy0, hy1, mul_nonneg (sq_nonneg (y-1)) (by linarith : (0:ℝ) ≤ 2*y+1)]
    show _ ≤ putnam_1991_a5_solution
    show _ ≤ 1/3
    linarith [step2, step3, step4]
