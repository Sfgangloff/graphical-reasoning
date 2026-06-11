import Mathlib

open scoped Real

noncomputable def putnam_1993_a1_solution : ℝ := 4 / 9

/--
The horizontal line `y = c` intersects the curve `y = 2x - 3x^3` in the first
quadrant.  Find `c` so that the areas of the two shaded regions are equal.
The answer is `c = 4/9`.
-/
theorem putnam_1993_a1 :
    0 < putnam_1993_a1_solution ∧
    putnam_1993_a1_solution < 4 * Real.sqrt 2 / 9 ∧
    ∃ x1 x2 : ℝ, 0 ≤ x1 ∧ x1 < x2 ∧
      2 * x1 - 3 * x1 ^ 3 = putnam_1993_a1_solution ∧
      2 * x2 - 3 * x2 ^ 3 = putnam_1993_a1_solution ∧
      (∫ x in (0:ℝ)..x1, (putnam_1993_a1_solution - (2 * x - 3 * x ^ 3)))
        = ∫ x in x1..x2, ((2 * x - 3 * x ^ 3) - putnam_1993_a1_solution) := by
  unfold putnam_1993_a1_solution
  -- basic facts about square roots
  have h3 : Real.sqrt 3 ^ 2 = 3 := Real.sq_sqrt (by norm_num)
  have h3nn : (0:ℝ) ≤ Real.sqrt 3 := Real.sqrt_nonneg 3
  have h2 : Real.sqrt 2 ^ 2 = 2 := Real.sq_sqrt (by norm_num)
  have h2nn : (0:ℝ) ≤ Real.sqrt 2 := Real.sqrt_nonneg 2
  refine ⟨by norm_num, ?_, (Real.sqrt 3 - 1) / 3, 2 / 3, ?_, ?_, ?_, ?_, ?_⟩
  · -- 4/9 < 4*√2/9
    nlinarith [h2, h2nn]
  · -- 0 ≤ (√3 - 1)/3
    nlinarith [h3, h3nn]
  · -- (√3-1)/3 < 2/3
    nlinarith [h3, h3nn]
  · -- f(x1) = 4/9
    linear_combination ((3 - Real.sqrt 3) / 9) * h3
  · -- f(x2) = 4/9
    norm_num
  · -- the area equality
    -- antiderivative evaluation for the integrand  4/9 - (2x - 3x^3)
    have hint1 : ∀ a b : ℝ,
        (∫ x in a..b, ((4:ℝ)/9 - (2 * x - 3 * x ^ 3)))
          = ((4:ℝ)/9 * b - b ^ 2 + 3/4 * b ^ 4) - ((4:ℝ)/9 * a - a ^ 2 + 3/4 * a ^ 4) := by
      intro a b
      have hderiv : ∀ x : ℝ,
          HasDerivAt (fun y : ℝ => (4:ℝ)/9 * y - y ^ 2 + 3/4 * y ^ 4)
            ((4:ℝ)/9 - (2 * x - 3 * x ^ 3)) x := by
        intro x
        have h := (((hasDerivAt_id x).const_mul ((4:ℝ)/9)).sub (hasDerivAt_pow 2 x)).add
          ((hasDerivAt_pow 4 x).const_mul ((3:ℝ)/4))
        convert h using 1
        push_cast
        ring
      exact intervalIntegral.integral_eq_sub_of_hasDerivAt (fun x _ => hderiv x)
        ((by fun_prop : Continuous (fun x : ℝ => (4:ℝ)/9 - (2 * x - 3 * x ^ 3))).intervalIntegrable a b)
    -- antiderivative evaluation for the integrand  (2x - 3x^3) - 4/9
    have hint2 : ∀ a b : ℝ,
        (∫ x in a..b, ((2 * x - 3 * x ^ 3) - (4:ℝ)/9))
          = (b ^ 2 - 3/4 * b ^ 4 - (4:ℝ)/9 * b) - (a ^ 2 - 3/4 * a ^ 4 - (4:ℝ)/9 * a) := by
      intro a b
      have hderiv : ∀ x : ℝ,
          HasDerivAt (fun y : ℝ => y ^ 2 - 3/4 * y ^ 4 - (4:ℝ)/9 * y)
            ((2 * x - 3 * x ^ 3) - (4:ℝ)/9) x := by
        intro x
        have h := (((hasDerivAt_pow 2 x).sub ((hasDerivAt_pow 4 x).const_mul ((3:ℝ)/4))).sub
          ((hasDerivAt_id x).const_mul ((4:ℝ)/9)))
        convert h using 1
        push_cast
        ring
      exact intervalIntegral.integral_eq_sub_of_hasDerivAt (fun x _ => hderiv x)
        ((by fun_prop : Continuous (fun x : ℝ => (2 * x - 3 * x ^ 3) - (4:ℝ)/9)).intervalIntegrable a b)
    rw [hint1, hint2]
    ring
