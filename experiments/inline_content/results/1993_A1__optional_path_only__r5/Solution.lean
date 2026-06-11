import Mathlib

open intervalIntegral MeasureTheory

noncomputable def putnam_1993_a1_solution : ℝ := 4 / 9

theorem putnam_1993_a1 :
    0 < putnam_1993_a1_solution ∧ putnam_1993_a1_solution < 4 * Real.sqrt 2 / 9 ∧
    ∃ x1 x2 : ℝ, 0 < x1 ∧ x1 < x2 ∧
      2 * x1 - 3 * x1 ^ 3 = putnam_1993_a1_solution ∧
      2 * x2 - 3 * x2 ^ 3 = putnam_1993_a1_solution ∧
      (∫ x in (0:ℝ)..x1, (putnam_1993_a1_solution - (2 * x - 3 * x ^ 3))) =
        (∫ x in x1..x2, ((2 * x - 3 * x ^ 3) - putnam_1993_a1_solution)) := by
  -- integrability of the cubic
  have poly_int : ∀ a b : ℝ, IntervalIntegrable (fun x : ℝ => 2 * x - 3 * x ^ 3) volume a b := by
    intro a b
    apply Continuous.intervalIntegrable
    fun_prop
  -- antiderivative computation
  have intpoly : ∀ a b : ℝ, (∫ x in a..b, (2 * x - 3 * x ^ 3)) =
      (b ^ 2 - 3 / 4 * b ^ 4) - (a ^ 2 - 3 / 4 * a ^ 4) := by
    intro a b
    have h1 : (∫ x in a..b, (2 * x - 3 * x ^ 3)) =
        (∫ x in a..b, (2 * x)) - (∫ x in a..b, (3 * x ^ 3)) := by
      apply intervalIntegral.integral_sub
      · exact (Continuous.intervalIntegrable (by fun_prop) a b)
      · exact (Continuous.intervalIntegrable (by fun_prop) a b)
    rw [h1, intervalIntegral.integral_const_mul, intervalIntegral.integral_const_mul,
      integral_id, integral_pow]
    norm_num
    ring
  have s3 : Real.sqrt 3 ^ 2 = 3 := Real.sq_sqrt (by norm_num)
  have hs3pos : (1 : ℝ) < Real.sqrt 3 := by
    nlinarith [Real.sqrt_nonneg 3, s3]
  have hs3lt : Real.sqrt 3 < 3 := by
    nlinarith [Real.sqrt_nonneg 3, s3]
  refine ⟨by norm_num [putnam_1993_a1_solution], ?_, (Real.sqrt 3 - 1) / 3, 2 / 3, ?_, ?_, ?_, ?_, ?_⟩
  · -- 4/9 < 4 √2 / 9
    have h2 : (1 : ℝ) < Real.sqrt 2 := by
      nlinarith [Real.sqrt_nonneg 2, Real.sq_sqrt (show (0:ℝ) ≤ 2 by norm_num)]
    simp only [putnam_1993_a1_solution]
    linarith
  · -- 0 < x1
    linarith
  · -- x1 < x2
    linarith
  · -- f x1 = sol
    simp only [putnam_1993_a1_solution]
    have e2 : ((Real.sqrt 3 - 1) / 3) ^ 2 = (4 - 2 * Real.sqrt 3) / 9 := by
      field_simp; nlinarith [s3]
    nlinarith [s3, e2]
  · -- f x2 = sol
    simp only [putnam_1993_a1_solution]; norm_num
  · -- equal areas
    rw [intervalIntegral.integral_sub _root_.intervalIntegrable_const (poly_int 0 _),
      intervalIntegral.integral_sub (poly_int _ _) _root_.intervalIntegrable_const,
      intervalIntegral.integral_const, intervalIntegral.integral_const,
      intpoly, intpoly]
    simp only [putnam_1993_a1_solution, smul_eq_mul]
    ring
