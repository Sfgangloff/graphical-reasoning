import Mathlib

open intervalIntegral

noncomputable def putnam_1993_a1_solution : ℝ := 4 / 9

theorem putnam_1993_a1 :
    0 < putnam_1993_a1_solution ∧ putnam_1993_a1_solution < 4 * Real.sqrt 2 / 9 ∧
    ∃ x₁ x₂ : ℝ, 0 < x₁ ∧ x₁ < x₂ ∧
      (2 * x₁ - 3 * x₁ ^ 3 = putnam_1993_a1_solution) ∧
      (2 * x₂ - 3 * x₂ ^ 3 = putnam_1993_a1_solution) ∧
      (∫ x in (0:ℝ)..x₁, (putnam_1993_a1_solution - (2 * x - 3 * x ^ 3))) =
      (∫ x in x₁..x₂, ((2 * x - 3 * x ^ 3) - putnam_1993_a1_solution)) := by
  have hs : Real.sqrt 3 ^ 2 = 3 := Real.sq_sqrt (by norm_num)
  have hs0 : 0 ≤ Real.sqrt 3 := Real.sqrt_nonneg 3
  refine ⟨by norm_num [putnam_1993_a1_solution], ?_, (Real.sqrt 3 - 1) / 3, 2 / 3, ?_, ?_, ?_, ?_, ?_⟩
  · -- solution < 4 * sqrt 2 / 9
    have h2 : Real.sqrt 2 ^ 2 = 2 := Real.sq_sqrt (by norm_num)
    have h20 : 0 ≤ Real.sqrt 2 := Real.sqrt_nonneg 2
    simp only [putnam_1993_a1_solution]
    nlinarith [h2, h20]
  · -- 0 < x₁
    nlinarith [hs, hs0]
  · -- x₁ < x₂
    nlinarith [hs, hs0]
  · -- f x₁ = solution
    simp only [putnam_1993_a1_solution]
    linear_combination (-(Real.sqrt 3 - 3) / 9) * hs
  · -- f x₂ = solution
    simp only [putnam_1993_a1_solution]
    norm_num
  · -- integral equality
    have hF1 : (∫ x in (0:ℝ)..((Real.sqrt 3 - 1) / 3),
        (putnam_1993_a1_solution - (2 * x - 3 * x ^ 3)))
        = (fun y : ℝ => putnam_1993_a1_solution * y - y ^ 2 + (3 / 4) * y ^ 4) ((Real.sqrt 3 - 1) / 3)
          - (fun y : ℝ => putnam_1993_a1_solution * y - y ^ 2 + (3 / 4) * y ^ 4) 0 := by
      apply intervalIntegral.integral_eq_sub_of_hasDerivAt
        (f := fun y : ℝ => putnam_1993_a1_solution * y - y ^ 2 + (3 / 4) * y ^ 4)
        (f' := fun x : ℝ => putnam_1993_a1_solution - (2 * x - 3 * x ^ 3))
      · intro x _
        have h1 : HasDerivAt (fun y : ℝ => putnam_1993_a1_solution * y) (putnam_1993_a1_solution * 1) x :=
          (hasDerivAt_id x).const_mul putnam_1993_a1_solution
        have h2 := hasDerivAt_pow 2 x
        have h3 := (hasDerivAt_pow 4 x).const_mul (3 / 4 : ℝ)
        convert (h1.sub h2).add h3 using 1
        push_cast; ring
      · apply Continuous.intervalIntegrable
        fun_prop
    have hF2 : (∫ x in ((Real.sqrt 3 - 1) / 3)..(2/3),
        ((2 * x - 3 * x ^ 3) - putnam_1993_a1_solution))
        = (fun y : ℝ => -(putnam_1993_a1_solution * y) + y ^ 2 - (3 / 4) * y ^ 4) (2/3)
          - (fun y : ℝ => -(putnam_1993_a1_solution * y) + y ^ 2 - (3 / 4) * y ^ 4) ((Real.sqrt 3 - 1) / 3) := by
      apply intervalIntegral.integral_eq_sub_of_hasDerivAt
        (f := fun y : ℝ => -(putnam_1993_a1_solution * y) + y ^ 2 - (3 / 4) * y ^ 4)
        (f' := fun x : ℝ => (2 * x - 3 * x ^ 3) - putnam_1993_a1_solution)
      · intro x _
        have h1 : HasDerivAt (fun y : ℝ => -(putnam_1993_a1_solution * y)) (-(putnam_1993_a1_solution * 1)) x :=
          ((hasDerivAt_id x).const_mul putnam_1993_a1_solution).neg
        have h2 := hasDerivAt_pow 2 x
        have h3 := (hasDerivAt_pow 4 x).const_mul (3 / 4 : ℝ)
        convert (h1.add h2).sub h3 using 1
        push_cast; ring
      · apply Continuous.intervalIntegrable
        fun_prop
    rw [hF1, hF2]
    simp only [putnam_1993_a1_solution]
    ring
