import Mathlib

noncomputable def putnam_1993_a1_solution : ℝ := 4 / 9

/-- 1993 A1. The horizontal line `y = c` meets the curve `y = 2x - 3x^3` in the
first quadrant at two points `a < b`. The value of `c` for which the two shaded
regions (left of `a` between line and curve, and between `a` and `b` between curve
and line) have equal area is `c = 4/9`. -/
theorem putnam_1993_a1 :
    0 < putnam_1993_a1_solution ∧
    putnam_1993_a1_solution < 4 * Real.sqrt 2 / 9 ∧
    ∃ a b : ℝ, 0 < a ∧ a < b ∧
      2 * a - 3 * a ^ 3 = putnam_1993_a1_solution ∧
      2 * b - 3 * b ^ 3 = putnam_1993_a1_solution ∧
      (∫ x in (0:ℝ)..a, (putnam_1993_a1_solution - (2 * x - 3 * x ^ 3)))
        = ∫ x in a..b, ((2 * x - 3 * x ^ 3) - putnam_1993_a1_solution) := by
  unfold putnam_1993_a1_solution
  have hs : Real.sqrt 3 ^ 2 = 3 := Real.sq_sqrt (by norm_num)
  have hs0 : (0:ℝ) ≤ Real.sqrt 3 := Real.sqrt_nonneg 3
  -- antiderivative G t = 4/9 t - t^2 + 3/4 t^4 has derivative 4/9 - (2t - 3t^3)
  have hderiv : ∀ x : ℝ, HasDerivAt (fun t : ℝ => 4/9 * t - t^2 + 3/4 * t^4)
      (4/9 - (2 * x - 3 * x ^ 3)) x := by
    intro x
    have h := (((hasDerivAt_id x).const_mul (4/9 : ℝ)).sub (hasDerivAt_pow 2 x)).add
              ((hasDerivAt_pow 4 x).const_mul (3/4 : ℝ))
    convert h using 1
    push_cast
    ring
  have key : ∀ p q : ℝ, (∫ x in p..q, (4/9 - (2 * x - 3 * x ^ 3)))
      = (4/9 * q - q^2 + 3/4 * q^4) - (4/9 * p - p^2 + 3/4 * p^4) := by
    intro p q
    rw [intervalIntegral.integral_eq_sub_of_hasDerivAt (fun x _ => hderiv x)
        ((show Continuous (fun x : ℝ => (4:ℝ)/9 - (2 * x - 3 * x ^ 3)) by fun_prop).intervalIntegrable p q)]
  have key2 : ∀ p q : ℝ, (∫ x in p..q, ((2 * x - 3 * x ^ 3) - 4/9))
      = -(4/9 * q - q^2 + 3/4 * q^4) - -(4/9 * p - p^2 + 3/4 * p^4) := by
    intro p q
    have hderiv2 : ∀ x : ℝ, HasDerivAt (fun t : ℝ => -(4/9 * t - t^2 + 3/4 * t^4))
        ((2 * x - 3 * x ^ 3) - 4/9) x := by
      intro x
      have := (hderiv x).neg
      convert this using 1
      ring
    rw [intervalIntegral.integral_eq_sub_of_hasDerivAt (fun x _ => hderiv2 x)
        ((show Continuous (fun x : ℝ => (2 * x - 3 * x ^ 3) - (4:ℝ)/9) by fun_prop).intervalIntegrable p q)]
  refine ⟨by norm_num, ?_, (Real.sqrt 3 - 1)/3, 2/3, ?_, ?_, ?_, ?_, ?_⟩
  · -- 4/9 < 4 √2 / 9
    nlinarith [Real.sq_sqrt (show (0:ℝ) ≤ 2 by norm_num), Real.sqrt_nonneg 2]
  · -- 0 < a
    nlinarith [hs, hs0]
  · -- a < b
    nlinarith [hs, hs0]
  · -- f a = 4/9
    linear_combination ((3 - Real.sqrt 3) / 9) * hs
  · -- f b = 4/9
    norm_num
  · -- equal areas
    rw [key 0 ((Real.sqrt 3 - 1)/3), key2 ((Real.sqrt 3 - 1)/3) (2/3)]
    ring_nf
