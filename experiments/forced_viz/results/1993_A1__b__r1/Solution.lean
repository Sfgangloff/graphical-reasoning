import Mathlib

open MeasureTheory intervalIntegral

noncomputable def putnam_1993_a1_solution : ℝ := 4 / 9

theorem putnam_1993_a1 :
    0 < putnam_1993_a1_solution ∧
    putnam_1993_a1_solution < 4 * Real.sqrt 2 / 9 ∧
    (∃ x1 x2 : ℝ, x1 < x2 ∧
      2 * x1 - 3 * x1 ^ 3 = putnam_1993_a1_solution ∧
      2 * x2 - 3 * x2 ^ 3 = putnam_1993_a1_solution ∧
      0 ≤ x1 ∧
      (∫ x in x1..x2, (2 * x - 3 * x ^ 3 - putnam_1993_a1_solution)) =
        (∫ x in (0 : ℝ)..x1, (putnam_1993_a1_solution - (2 * x - 3 * x ^ 3)))) := by
  have hs3 : Real.sqrt 3 ^ 2 = 3 := Real.sq_sqrt (by norm_num)
  have hs3nn : (0 : ℝ) ≤ Real.sqrt 3 := Real.sqrt_nonneg 3
  have hs2 : Real.sqrt 2 ^ 2 = 2 := Real.sq_sqrt (by norm_num)
  have hs2nn : (0 : ℝ) ≤ Real.sqrt 2 := Real.sqrt_nonneg 2
  -- antiderivative of  2x - 3x^3 - 4/9
  have hF : ∀ x : ℝ,
      HasDerivAt (fun y : ℝ => y ^ 2 - 3 / 4 * y ^ 4 - 4 / 9 * y)
        (2 * x - 3 * x ^ 3 - 4 / 9) x := by
    intro x
    have h1 := hasDerivAt_pow 2 x
    have h2 := (hasDerivAt_pow 4 x).const_mul (3 / 4 : ℝ)
    have h3 := (hasDerivAt_id x).const_mul (4 / 9 : ℝ)
    convert (h1.sub h2).sub h3 using 1
    push_cast
    ring
  -- ∫ (2x - 3x^3 - 4/9) = P b - P a
  have key : ∀ a b : ℝ, (∫ x in a..b, (2 * x - 3 * x ^ 3 - 4 / 9)) =
      (b ^ 2 - 3 / 4 * b ^ 4 - 4 / 9 * b) - (a ^ 2 - 3 / 4 * a ^ 4 - 4 / 9 * a) := by
    intro a b
    have h := intervalIntegral.integral_eq_sub_of_hasDerivAt
      (f := fun y : ℝ => y ^ 2 - 3 / 4 * y ^ 4 - 4 / 9 * y)
      (f' := fun x : ℝ => 2 * x - 3 * x ^ 3 - 4 / 9)
      (a := a) (b := b) (fun x _ => hF x)
      (by apply Continuous.intervalIntegrable; fun_prop)
    simpa using h
  -- ∫ (4/9 - (2x - 3x^3)) = -P b + P a
  have key2 : ∀ a b : ℝ, (∫ x in a..b, (4 / 9 - (2 * x - 3 * x ^ 3))) =
      (-(b ^ 2 - 3 / 4 * b ^ 4 - 4 / 9 * b)) - (-(a ^ 2 - 3 / 4 * a ^ 4 - 4 / 9 * a)) := by
    intro a b
    have hd : ∀ x : ℝ, HasDerivAt (fun y : ℝ => -(y ^ 2 - 3 / 4 * y ^ 4 - 4 / 9 * y))
        (4 / 9 - (2 * x - 3 * x ^ 3)) x := by
      intro x
      have := (hF x).neg
      convert this using 1
      ring
    have h := intervalIntegral.integral_eq_sub_of_hasDerivAt
      (f := fun y : ℝ => -(y ^ 2 - 3 / 4 * y ^ 4 - 4 / 9 * y))
      (f' := fun x : ℝ => 4 / 9 - (2 * x - 3 * x ^ 3))
      (a := a) (b := b) (fun x _ => hd x)
      (by apply Continuous.intervalIntegrable; fun_prop)
    simpa using h
  refine ⟨by norm_num [putnam_1993_a1_solution], ?_, (Real.sqrt 3 - 1) / 3, 2 / 3, ?_, ?_, ?_, ?_, ?_⟩
  · -- 4/9 < 4 √2 / 9
    rw [putnam_1993_a1_solution]
    nlinarith [hs2, hs2nn]
  · -- x1 < x2
    nlinarith [hs3, hs3nn]
  · -- 2 x1 - 3 x1^3 = 4/9
    rw [putnam_1993_a1_solution]
    linear_combination ((3 - Real.sqrt 3) / 9) * hs3
  · -- 2 x2 - 3 x2^3 = 4/9
    rw [putnam_1993_a1_solution]; norm_num
  · -- 0 ≤ x1
    nlinarith [hs3, hs3nn]
  · -- the integral identity
    rw [putnam_1993_a1_solution, key, key2]
    ring
