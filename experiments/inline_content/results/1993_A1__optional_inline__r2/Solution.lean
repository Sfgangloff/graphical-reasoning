import Mathlib

noncomputable def putnam_1993_a1_solution : ℝ := 4 / 9

theorem putnam_1993_a1 :
    0 < putnam_1993_a1_solution ∧
    putnam_1993_a1_solution < 4 * Real.sqrt 2 / 9 ∧
    ∃ a b : ℝ, 0 < a ∧ a < b ∧
      2 * a - 3 * a ^ 3 = putnam_1993_a1_solution ∧
      2 * b - 3 * b ^ 3 = putnam_1993_a1_solution ∧
      (∫ x in (0 : ℝ)..a, (putnam_1993_a1_solution - (2 * x - 3 * x ^ 3)))
        = (∫ x in a..b, ((2 * x - 3 * x ^ 3) - putnam_1993_a1_solution)) := by
  simp only [putnam_1993_a1_solution]
  have hs : Real.sqrt 3 ^ 2 = 3 := Real.sq_sqrt (by norm_num)
  have h2 : (1 : ℝ) < Real.sqrt 2 := by
    nlinarith [Real.sq_sqrt (show (0 : ℝ) ≤ 2 by norm_num), Real.sqrt_nonneg 2]
  have h3 : (1 : ℝ) < Real.sqrt 3 := by nlinarith [hs, Real.sqrt_nonneg 3]
  have h4 : Real.sqrt 3 < 3 := by nlinarith [hs, Real.sqrt_nonneg 3]
  refine ⟨by norm_num, ?_, (Real.sqrt 3 - 1) / 3, 2 / 3, ?_, ?_, ?_, ?_, ?_⟩
  · -- 4/9 < 4√2/9
    linarith
  · -- 0 < a
    linarith
  · -- a < b
    linarith
  · -- f a = 4/9
    linear_combination ((3 - Real.sqrt 3) / 9) * hs
  · -- f b = 4/9
    norm_num
  · -- integral equality
    have hGderiv : ∀ x ∈ Set.uIcc (0 : ℝ) ((Real.sqrt 3 - 1) / 3),
        HasDerivAt (fun x : ℝ => 4 / 9 * x - x ^ 2 + 3 / 4 * x ^ 4)
          (4 / 9 - (2 * x - 3 * x ^ 3)) x := by
      intro x _
      have e1 : HasDerivAt (fun x : ℝ => 4 / 9 * x) (4 / 9) x := by
        simpa using (hasDerivAt_id x).const_mul (4 / 9 : ℝ)
      have e2 : HasDerivAt (fun x : ℝ => x ^ 2) (2 * x) x := by
        simpa using hasDerivAt_pow 2 x
      have e3 : HasDerivAt (fun x : ℝ => 3 / 4 * x ^ 4) (3 / 4 * (4 * x ^ 3)) x := by
        simpa using (hasDerivAt_pow 4 x).const_mul (3 / 4 : ℝ)
      have := (e1.sub e2).add e3
      convert this using 1
      ring
    have hHderiv : ∀ x ∈ Set.uIcc ((Real.sqrt 3 - 1) / 3) (2 / 3 : ℝ),
        HasDerivAt (fun x : ℝ => x ^ 2 - 3 / 4 * x ^ 4 - 4 / 9 * x)
          ((2 * x - 3 * x ^ 3) - 4 / 9) x := by
      intro x _
      have e1 : HasDerivAt (fun x : ℝ => x ^ 2) (2 * x) x := by
        simpa using hasDerivAt_pow 2 x
      have e2 : HasDerivAt (fun x : ℝ => 3 / 4 * x ^ 4) (3 / 4 * (4 * x ^ 3)) x := by
        simpa using (hasDerivAt_pow 4 x).const_mul (3 / 4 : ℝ)
      have e3 : HasDerivAt (fun x : ℝ => 4 / 9 * x) (4 / 9) x := by
        simpa using (hasDerivAt_id x).const_mul (4 / 9 : ℝ)
      have := (e1.sub e2).sub e3
      convert this using 1
      ring
    have hGint : IntervalIntegrable (fun x : ℝ => 4 / 9 - (2 * x - 3 * x ^ 3))
        MeasureTheory.volume 0 ((Real.sqrt 3 - 1) / 3) :=
      (by fun_prop : Continuous (fun x : ℝ => 4 / 9 - (2 * x - 3 * x ^ 3))).intervalIntegrable _ _
    have hHint : IntervalIntegrable (fun x : ℝ => (2 * x - 3 * x ^ 3) - 4 / 9)
        MeasureTheory.volume ((Real.sqrt 3 - 1) / 3) (2 / 3) :=
      (by fun_prop : Continuous (fun x : ℝ => (2 * x - 3 * x ^ 3) - 4 / 9)).intervalIntegrable _ _
    have hL : (∫ x in (0 : ℝ)..((Real.sqrt 3 - 1) / 3), (4 / 9 - (2 * x - 3 * x ^ 3)))
        = (4 / 9 * ((Real.sqrt 3 - 1) / 3) - ((Real.sqrt 3 - 1) / 3) ^ 2
            + 3 / 4 * ((Real.sqrt 3 - 1) / 3) ^ 4)
          - (4 / 9 * 0 - (0 : ℝ) ^ 2 + 3 / 4 * 0 ^ 4) :=
      intervalIntegral.integral_eq_sub_of_hasDerivAt hGderiv hGint
    have hR : (∫ x in ((Real.sqrt 3 - 1) / 3)..(2 / 3 : ℝ), ((2 * x - 3 * x ^ 3) - 4 / 9))
        = ((2 / 3 : ℝ) ^ 2 - 3 / 4 * (2 / 3) ^ 4 - 4 / 9 * (2 / 3))
          - (((Real.sqrt 3 - 1) / 3) ^ 2 - 3 / 4 * ((Real.sqrt 3 - 1) / 3) ^ 4
              - 4 / 9 * ((Real.sqrt 3 - 1) / 3)) :=
      intervalIntegral.integral_eq_sub_of_hasDerivAt hHderiv hHint
    rw [hL, hR]
    ring
