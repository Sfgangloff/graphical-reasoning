import Mathlib

open intervalIntegral MeasureTheory

noncomputable def putnam_1993_a1_solution : ℝ := 4 / 9

/-- Antiderivative computation for the relevant polynomial integrand. -/
lemma poly_integral (c t : ℝ) :
    (∫ x in (0:ℝ)..t, (c - (2 * x - 3 * x ^ 3))) = c * t - t ^ 2 + (3 / 4) * t ^ 4 := by
  have h : (∫ x in (0:ℝ)..t, (c - (2 * x - 3 * x ^ 3)))
      = (fun x : ℝ => c * x - x ^ 2 + (3 / 4) * x ^ 4) t
        - (fun x : ℝ => c * x - x ^ 2 + (3 / 4) * x ^ 4) 0 := by
    apply intervalIntegral.integral_eq_sub_of_hasDerivAt
    · intro x _
      have d1 : HasDerivAt (fun x : ℝ => c * x) c x := by
        simpa using (hasDerivAt_id x).const_mul c
      have d2 : HasDerivAt (fun x : ℝ => x ^ 2) (2 * x) x := by
        simpa using hasDerivAt_pow 2 x
      have d3 : HasDerivAt (fun x : ℝ => (3 / 4) * x ^ 4) ((3 / 4) * (4 * x ^ 3)) x := by
        have := (hasDerivAt_pow 4 x).const_mul (3 / 4 : ℝ)
        simpa using this
      have := (d1.sub d2).add d3
      convert this using 1
      ring
    · apply Continuous.intervalIntegrable
      fun_prop
  simpa using h

theorem putnam_1993_a1
    (c a b : ℝ)
    (ha : 0 < a) (hab : a < b)
    (hfa : 2 * a - 3 * a ^ 3 = c) (hfb : 2 * b - 3 * b ^ 3 = c)
    (harea : (∫ x in (0:ℝ)..a, (c - (2 * x - 3 * x ^ 3)))
        = ∫ x in a..b, ((2 * x - 3 * x ^ 3) - c)) :
    c = putnam_1993_a1_solution := by
  have hb : 0 < b := lt_trans ha hab
  -- the integrand g x = c - (2x - 3x^3) is continuous, hence interval integrable
  have hcont : Continuous (fun x : ℝ => c - (2 * x - 3 * x ^ 3)) := by fun_prop
  -- rewrite the right region integral as the negation of g's integral
  have hneg : (∫ x in a..b, ((2 * x - 3 * x ^ 3) - c))
      = -(∫ x in a..b, (c - (2 * x - 3 * x ^ 3))) := by
    have hfun : (fun x : ℝ => (2 * x - 3 * x ^ 3) - c)
        = (fun x : ℝ => -(c - (2 * x - 3 * x ^ 3))) := by funext x; ring
    rw [hfun, intervalIntegral.integral_neg]
  -- additivity of adjacent integrals
  have hadd : (∫ x in (0:ℝ)..a, (c - (2 * x - 3 * x ^ 3)))
      + (∫ x in a..b, (c - (2 * x - 3 * x ^ 3)))
      = ∫ x in (0:ℝ)..b, (c - (2 * x - 3 * x ^ 3)) :=
    intervalIntegral.integral_add_adjacent_intervals
      (hcont.intervalIntegrable _ _) (hcont.intervalIntegrable _ _)
  -- combine: the full integral from 0 to b vanishes
  have hzero : (∫ x in (0:ℝ)..b, (c - (2 * x - 3 * x ^ 3))) = 0 := by
    rw [← hadd, harea, hneg]; ring
  -- evaluate via the antiderivative
  rw [poly_integral] at hzero
  -- hzero : c * b - b ^ 2 + (3 / 4) * b ^ 4 = 0
  -- substitute c = 2b - 3b^3
  rw [← hfb] at hzero
  -- now hzero : (2b - 3b^3) * b - b^2 + (3/4) b^4 = 0, i.e. b^2 - (9/4) b^4 = 0
  have hpoly : b ^ 2 * (1 - (9 / 4) * b ^ 2) = 0 := by nlinarith [hzero]
  have hb2 : b ^ 2 = 4 / 9 := by
    rcases mul_eq_zero.mp hpoly with h | h
    · exact absurd h (by positivity)
    · nlinarith [h]
  have hbval : b = 2 / 3 := by nlinarith [hb2, hb]
  rw [show putnam_1993_a1_solution = 4 / 9 from rfl, ← hfb, hbval]
  norm_num
