import Mathlib

noncomputable def putnam_1993_a1_solution : ℝ := 4 / 9

theorem putnam_1993_a1 :
    0 < putnam_1993_a1_solution ∧
    putnam_1993_a1_solution < 4 * Real.sqrt 2 / 9 ∧
    ∃ x1 x2 : ℝ, 0 < x1 ∧ x1 < x2 ∧
      2 * x1 - 3 * x1 ^ 3 = putnam_1993_a1_solution ∧
      2 * x2 - 3 * x2 ^ 3 = putnam_1993_a1_solution ∧
      (∫ x in (0:ℝ)..x1, (putnam_1993_a1_solution - (2 * x - 3 * x ^ 3))) =
        (∫ x in x1..x2, ((2 * x - 3 * x ^ 3) - putnam_1993_a1_solution)) := by
  have h3 : Real.sqrt 3 ^ 2 = 3 := Real.sq_sqrt (by norm_num)
  have h3nn : (0:ℝ) ≤ Real.sqrt 3 := Real.sqrt_nonneg 3
  have h3gt1 : (1:ℝ) < Real.sqrt 3 := by nlinarith [h3, h3nn]
  have h3lt3 : Real.sqrt 3 < 3 := by nlinarith [h3, h3nn]
  refine ⟨by norm_num [putnam_1993_a1_solution], ?_, (Real.sqrt 3 - 1)/3, 2/3, ?_, ?_, ?_, ?_, ?_⟩
  · have h2 : (1:ℝ) < Real.sqrt 2 := by
      nlinarith [Real.sq_sqrt (show (0:ℝ) ≤ 2 by norm_num), Real.sqrt_nonneg 2]
    rw [putnam_1993_a1_solution]; linarith [h2]
  · linarith [h3gt1]
  · linarith [h3lt3]
  · rw [putnam_1993_a1_solution]
    linear_combination ((3 - Real.sqrt 3)/9) * h3
  · rw [putnam_1993_a1_solution]; norm_num
  · simp only [putnam_1993_a1_solution]
    have hg : Continuous (fun x : ℝ => 4 / 9 - (2 * x - 3 * x ^ 3)) := by fun_prop
    have key : ∫ x in (0:ℝ)..(2/3), (4 / 9 - (2 * x - 3 * x ^ 3)) = 0 := by
      have hd : ∀ x ∈ Set.uIcc (0:ℝ) (2/3),
          HasDerivAt (fun y => (4:ℝ)/9 * y - y^2 + 3/4 * y^4)
            (4 / 9 - (2 * x - 3 * x ^ 3)) x := by
        intro x _
        have d := ((hasDerivAt_id x).const_mul ((4:ℝ)/9)).sub (hasDerivAt_pow 2 x)
        have d2 := d.add ((hasDerivAt_pow 4 x).const_mul ((3:ℝ)/4))
        convert d2 using 1
        push_cast; ring
      rw [intervalIntegral.integral_eq_sub_of_hasDerivAt hd (hg.intervalIntegrable _ _)]
      norm_num
    have hrhs : (∫ x in ((Real.sqrt 3 - 1)/3)..(2/3), ((2 * x - 3 * x ^ 3) - 4 / 9))
        = - ∫ x in ((Real.sqrt 3 - 1)/3)..(2/3), (4 / 9 - (2 * x - 3 * x ^ 3)) := by
      rw [← intervalIntegral.integral_neg]; congr 1; ext x; ring
    rw [hrhs]
    have hadd : (∫ x in (0:ℝ)..((Real.sqrt 3 - 1)/3), (4 / 9 - (2 * x - 3 * x ^ 3)))
        + (∫ x in ((Real.sqrt 3 - 1)/3)..(2/3), (4 / 9 - (2 * x - 3 * x ^ 3)))
        = ∫ x in (0:ℝ)..(2/3), (4 / 9 - (2 * x - 3 * x ^ 3)) :=
      intervalIntegral.integral_add_adjacent_intervals
        (hg.intervalIntegrable _ _) (hg.intervalIntegrable _ _)
    rw [key] at hadd
    linarith [hadd]
