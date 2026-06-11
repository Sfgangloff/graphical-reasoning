import Mathlib

open MeasureTheory intervalIntegral

noncomputable def putnam_1993_a1_solution : ℝ := 4 / 9

theorem putnam_1993_a1 :
    putnam_1993_a1_solution ∈ Set.Ioo (0 : ℝ) (4 * Real.sqrt 2 / 9) ∧
    ∃ x1 x2 : ℝ, 0 < x1 ∧ x1 < x2 ∧
      2 * x1 - 3 * x1 ^ 3 = putnam_1993_a1_solution ∧
      2 * x2 - 3 * x2 ^ 3 = putnam_1993_a1_solution ∧
      (∫ x in (0 : ℝ)..x1, (putnam_1993_a1_solution - (2 * x - 3 * x ^ 3))) =
      (∫ x in (x1 : ℝ)..x2, ((2 * x - 3 * x ^ 3) - putnam_1993_a1_solution)) := by
  have hs : Real.sqrt 3 ^ 2 = 3 := Real.sq_sqrt (by norm_num)
  have hs1 : (1 : ℝ) < Real.sqrt 3 := by
    have := Real.lt_sqrt (x := (1:ℝ)) (y := 3) (by norm_num)
    simpa using (by nlinarith [Real.sq_sqrt (show (0:ℝ) ≤ 3 by norm_num),
      Real.sqrt_nonneg 3] : (1:ℝ) < Real.sqrt 3)
  -- antiderivative evaluation
  have key : ∀ a b : ℝ,
      (∫ x in a..b, (putnam_1993_a1_solution - (2 * x - 3 * x ^ 3))) =
      (putnam_1993_a1_solution * b - b ^ 2 + 3 / 4 * b ^ 4) -
      (putnam_1993_a1_solution * a - a ^ 2 + 3 / 4 * a ^ 4) := by
    intro a b
    have : (∫ x in a..b, (putnam_1993_a1_solution - (2 * x - 3 * x ^ 3))) =
        (fun t : ℝ => putnam_1993_a1_solution * t - t ^ 2 + 3 / 4 * t ^ 4) b -
        (fun t : ℝ => putnam_1993_a1_solution * t - t ^ 2 + 3 / 4 * t ^ 4) a := by
      apply intervalIntegral.integral_eq_sub_of_hasDerivAt
        (f := fun t : ℝ => putnam_1993_a1_solution * t - t ^ 2 + 3 / 4 * t ^ 4)
      · intro x _
        convert (((hasDerivAt_id x).const_mul putnam_1993_a1_solution).sub
          (hasDerivAt_pow 2 x)).add ((hasDerivAt_pow 4 x).const_mul (3 / 4 : ℝ)) using 1
        push_cast; ring
      · apply Continuous.intervalIntegrable; fun_prop
    simpa using this
  refine ⟨⟨by norm_num [putnam_1993_a1_solution], ?_⟩, (Real.sqrt 3 - 1) / 3, 2 / 3,
    by linarith, by nlinarith [hs, Real.sqrt_nonneg 3], ?_,
    by norm_num [putnam_1993_a1_solution], ?_⟩
  · -- 4/9 < 4 * sqrt 2 / 9
    rw [putnam_1993_a1_solution]
    have : (1 : ℝ) < Real.sqrt 2 := by
      have := Real.sq_sqrt (show (0:ℝ) ≤ 2 by norm_num)
      nlinarith [Real.sqrt_nonneg 2]
    nlinarith
  · -- 2 * x1 - 3 * x1 ^ 3 = 4/9
    rw [putnam_1993_a1_solution]
    have hcube : Real.sqrt 3 ^ 3 = 3 * Real.sqrt 3 := by
      have : Real.sqrt 3 ^ 3 = Real.sqrt 3 ^ 2 * Real.sqrt 3 := by ring
      rw [this, hs]
    field_simp
    nlinarith [hs, hcube]
  · -- integral equality
    have hneg : (fun x : ℝ => (2 * x - 3 * x ^ 3) - putnam_1993_a1_solution) =
        (fun x : ℝ => -(putnam_1993_a1_solution - (2 * x - 3 * x ^ 3))) := by
      funext x; ring
    rw [show (∫ x in ((Real.sqrt 3 - 1) / 3)..(2/3 : ℝ),
        ((2 * x - 3 * x ^ 3) - putnam_1993_a1_solution)) =
        (∫ x in ((Real.sqrt 3 - 1) / 3)..(2/3 : ℝ),
        (-(putnam_1993_a1_solution - (2 * x - 3 * x ^ 3)))) from by rw [hneg]]
    rw [intervalIntegral.integral_neg, key, key]
    rw [putnam_1993_a1_solution]
    ring

