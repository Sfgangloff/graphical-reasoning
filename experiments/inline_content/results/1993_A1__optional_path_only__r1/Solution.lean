import Mathlib

open MeasureTheory intervalIntegral

noncomputable def putnam_1993_a1_solution : ℝ := 4 / 9

theorem putnam_1993_a1 :
    (0 < putnam_1993_a1_solution) ∧
    ∃ x1 x2 : ℝ, 0 < x1 ∧ x1 < x2 ∧
      2 * x1 - 3 * x1 ^ 3 = putnam_1993_a1_solution ∧
      2 * x2 - 3 * x2 ^ 3 = putnam_1993_a1_solution ∧
      (∫ x in (0:ℝ)..x1, (putnam_1993_a1_solution - (2 * x - 3 * x ^ 3))) =
        (∫ x in x1..x2, ((2 * x - 3 * x ^ 3) - putnam_1993_a1_solution)) := by
  -- antiderivative facts via FTC
  have key : ∀ a b : ℝ,
      (∫ x in a..b, (putnam_1993_a1_solution - (2 * x - 3 * x ^ 3))) =
        (putnam_1993_a1_solution * b - b ^ 2 + 3 / 4 * b ^ 4) -
          (putnam_1993_a1_solution * a - a ^ 2 + 3 / 4 * a ^ 4) := by
    intro a b
    have hd : ∀ x : ℝ,
        HasDerivAt (fun y => putnam_1993_a1_solution * y - y ^ 2 + 3 / 4 * y ^ 4)
          (putnam_1993_a1_solution - (2 * x - 3 * x ^ 3)) x := by
      intro x
      have e1 : HasDerivAt (fun y => putnam_1993_a1_solution * y) putnam_1993_a1_solution x := by
        simpa using (hasDerivAt_id x).const_mul putnam_1993_a1_solution
      have e2 : HasDerivAt (fun y : ℝ => y ^ 2) (2 * x) x := by
        simpa using hasDerivAt_pow 2 x
      have e3 : HasDerivAt (fun y : ℝ => 3 / 4 * y ^ 4) (3 * x ^ 3) x := by
        have h := (hasDerivAt_pow 4 x).const_mul (3 / 4 : ℝ)
        convert h using 1 <;> ring
      have := (e1.sub e2).add e3
      convert this using 1 <;> ring
    rw [intervalIntegral.integral_eq_sub_of_hasDerivAt (fun x _ => hd x)
        ((by fun_prop : Continuous fun x : ℝ =>
          putnam_1993_a1_solution - (2 * x - 3 * x ^ 3)).intervalIntegrable a b)]
  have key2 : ∀ a b : ℝ,
      (∫ x in a..b, ((2 * x - 3 * x ^ 3) - putnam_1993_a1_solution)) =
        (b ^ 2 - 3 / 4 * b ^ 4 - putnam_1993_a1_solution * b) -
          (a ^ 2 - 3 / 4 * a ^ 4 - putnam_1993_a1_solution * a) := by
    intro a b
    have hd : ∀ x : ℝ,
        HasDerivAt (fun y => y ^ 2 - 3 / 4 * y ^ 4 - putnam_1993_a1_solution * y)
          ((2 * x - 3 * x ^ 3) - putnam_1993_a1_solution) x := by
      intro x
      have e1 : HasDerivAt (fun y : ℝ => y ^ 2) (2 * x) x := by
        simpa using hasDerivAt_pow 2 x
      have e2 : HasDerivAt (fun y : ℝ => 3 / 4 * y ^ 4) (3 * x ^ 3) x := by
        have h := (hasDerivAt_pow 4 x).const_mul (3 / 4 : ℝ)
        convert h using 1 <;> ring
      have e3 : HasDerivAt (fun y => putnam_1993_a1_solution * y) putnam_1993_a1_solution x := by
        simpa using (hasDerivAt_id x).const_mul putnam_1993_a1_solution
      have := (e1.sub e2).sub e3
      convert this using 1 <;> ring
    rw [intervalIntegral.integral_eq_sub_of_hasDerivAt (fun x _ => hd x)
        ((by fun_prop : Continuous fun x : ℝ =>
          (2 * x - 3 * x ^ 3) - putnam_1993_a1_solution).intervalIntegrable a b)]
  have hs : Real.sqrt 3 ^ 2 = 3 := Real.sq_sqrt (by norm_num)
  have hnn : (0:ℝ) ≤ Real.sqrt 3 := Real.sqrt_nonneg 3
  refine ⟨by simp only [putnam_1993_a1_solution]; norm_num,
    (Real.sqrt 3 - 1) / 3, 2 / 3, ?_, ?_, ?_, ?_, ?_⟩
  · -- 0 < x1
    have : (1:ℝ) < Real.sqrt 3 := by nlinarith [hs, hnn]
    linarith
  · -- x1 < x2
    have : Real.sqrt 3 < 3 := by nlinarith [hs, hnn]
    linarith
  · -- intersection at x1
    simp only [putnam_1993_a1_solution]
    linear_combination (-(Real.sqrt 3 - 3) / 9) * hs
  · -- intersection at x2
    simp only [putnam_1993_a1_solution]; norm_num
  · -- equal areas
    rw [key 0 ((Real.sqrt 3 - 1) / 3), key2 ((Real.sqrt 3 - 1) / 3) (2 / 3)]
    simp only [putnam_1993_a1_solution]
    ring
