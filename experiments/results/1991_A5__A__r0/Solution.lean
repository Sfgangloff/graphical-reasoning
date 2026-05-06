import Mathlib

open MeasureTheory intervalIntegral Set

noncomputable def putnam_1991_a5_solution : ℝ := 1 / 3

-- Key inequality lemma: √(x⁴ + a²) ≤ x² + a when a ≥ 0
private lemma sqrt_le (x a : ℝ) (ha : 0 ≤ a) :
    Real.sqrt (x^4 + a^2) ≤ x^2 + a := by
  rw [show x^2 + a = Real.sqrt ((x^2 + a)^2) from
    (Real.sqrt_sq (by positivity)).symm]
  apply Real.sqrt_le_sqrt
  nlinarith [sq_nonneg x, sq_nonneg a, mul_nonneg (sq_nonneg x) ha]

theorem putnam_1991_a5 :
    IsGreatest
      ((fun y : ℝ => ∫ x in (0:ℝ)..y, Real.sqrt (x^4 + (y - y^2)^2)) '' Set.Icc 0 1)
      putnam_1991_a5_solution := by
  refine ⟨⟨1, ⟨by norm_num, le_refl _⟩, ?_⟩, ?_⟩
  · -- ∫ x in 0..1, sqrt (x^4 + 0) = 1/3
    simp only [putnam_1991_a5_solution]
    have h1 : ∀ x ∈ Set.uIcc (0:ℝ) 1, Real.sqrt (x^4 + (1 - 1^2)^2) = x^2 := by
      intro x _
      simp
      rw [show (x:ℝ)^4 = (x^2)^2 by ring, Real.sqrt_sq (sq_nonneg x)]
    rw [intervalIntegral.integral_congr h1]
    -- ∫ x in 0..1, x^2 = 1/3
    rw [integral_pow]
    norm_num
  · -- upper bound
    rintro v ⟨y, ⟨hy0, hy1⟩, rfl⟩
    -- Want: ∫ x in 0..y, sqrt(x^4 + (y - y^2)^2) ≤ 1/3
    have hyy : 0 ≤ y - y^2 := by nlinarith
    -- Use sqrt_le bound
    have hbound : ∀ x ∈ Set.uIcc (0:ℝ) y, Real.sqrt (x^4 + (y - y^2)^2) ≤ x^2 + (y - y^2) := by
      intro x _
      exact sqrt_le x (y - y^2) hyy
    have hint_le :
        (∫ x in (0:ℝ)..y, Real.sqrt (x^4 + (y - y^2)^2))
          ≤ ∫ x in (0:ℝ)..y, (x^2 + (y - y^2)) := by
      apply intervalIntegral.integral_mono_on hy0
      · -- IntervalIntegrable lhs
        apply Continuous.intervalIntegrable
        continuity
      · apply Continuous.intervalIntegrable
        continuity
      · intro x hx
        rcases hx with ⟨h1, h2⟩
        exact sqrt_le x (y - y^2) hyy
    -- Compute RHS
    have hcomp : (∫ x in (0:ℝ)..y, (x^2 + (y - y^2))) = y^3/3 + y * (y - y^2) := by
      rw [intervalIntegral.integral_add]
      · rw [integral_pow, intervalIntegral.integral_const]
        simp
        ring
      · apply Continuous.intervalIntegrable; continuity
      · apply Continuous.intervalIntegrable; continuity
    rw [hcomp] at hint_le
    -- Now need y^3/3 + y*(y - y^2) ≤ 1/3
    have hfinal : y^3/3 + y * (y - y^2) ≤ 1/3 := by
      nlinarith [sq_nonneg (1 - y), sq_nonneg y, mul_nonneg (sq_nonneg (1 - y)) (by linarith : (0:ℝ) ≤ 1 + 2*y)]
    show (∫ x in (0:ℝ)..y, Real.sqrt (x^4 + (y - y^2)^2)) ≤ putnam_1991_a5_solution
    simp only [putnam_1991_a5_solution]
    linarith [hint_le, hfinal]
