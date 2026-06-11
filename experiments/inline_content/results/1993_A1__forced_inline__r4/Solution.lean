import Mathlib

open Set

noncomputable def putnam_1993_a1_solution : ℝ := 4 / 9

theorem putnam_1993_a1 :
    ∃ a b : ℝ, 0 < a ∧ a < b ∧
      2 * a - 3 * a ^ 3 = putnam_1993_a1_solution ∧
      2 * b - 3 * b ^ 3 = putnam_1993_a1_solution ∧
      (∀ x ∈ Set.Ioo a b, putnam_1993_a1_solution < 2 * x - 3 * x ^ 3) ∧
      (∫ x in (0:ℝ)..a, (putnam_1993_a1_solution - (2 * x - 3 * x ^ 3)))
        = (∫ x in a..b, ((2 * x - 3 * x ^ 3) - putnam_1993_a1_solution)) := by
  simp only [putnam_1993_a1_solution]
  have h3 : Real.sqrt 3 ^ 2 = 3 := Real.sq_sqrt (by norm_num)
  have hs0 : (0:ℝ) ≤ Real.sqrt 3 := Real.sqrt_nonneg 3
  have h1lt : (1:ℝ) < Real.sqrt 3 := by nlinarith [h3, hs0]
  have hlt3 : Real.sqrt 3 < 3 := by nlinarith [h3, hs0]
  refine ⟨(Real.sqrt 3 - 1) / 3, 2 / 3, ?_, ?_, ?_, ?_, ?_, ?_⟩
  · -- 0 < a
    have : (0:ℝ) < Real.sqrt 3 - 1 := by linarith
    positivity
  · -- a < b
    linarith [hlt3]
  · -- f a = 4/9
    have ha2 : 9 * ((Real.sqrt 3 - 1) / 3) ^ 2 + 6 * ((Real.sqrt 3 - 1) / 3) - 2 = 0 := by
      linear_combination h3
    linear_combination (-(1/3) * ((Real.sqrt 3 - 1) / 3) + 2/9) * ha2
  · -- f b = 4/9
    norm_num
  · -- positivity on (a,b)
    intro x hx
    set a := (Real.sqrt 3 - 1) / 3 with ha_def
    have hapos : 0 < a := by
      rw [ha_def]
      have : (0:ℝ) < Real.sqrt 3 - 1 := by linarith
      positivity
    have ha2' : a ^ 2 + 2/3 * a - 2/9 = 0 := by
      rw [ha_def]; linear_combination (1/9 : ℝ) * h3
    have hxa : 0 < x - a := by linarith [hx.1]
    have hbx : 0 < 2/3 - x := by linarith [hx.2]
    have hxab : 0 < x + a + 2/3 := by linarith [hapos, hx.1]
    have hquad : 0 < x ^ 2 + 2/3 * x - 2/9 := by nlinarith [ha2', mul_pos hxa hxab]
    have hid : 2 * x - 3 * x ^ 3 - 4/9 = 3 * (2/3 - x) * (x ^ 2 + 2/3 * x - 2/9) := by ring
    nlinarith [hid, mul_pos hbx hquad]
  · -- equal areas
    set a := (Real.sqrt 3 - 1) / 3 with ha_def
    have hd1 : ∀ x ∈ uIcc (0:ℝ) a,
        HasDerivAt (fun y : ℝ => 4/9 * y - y ^ 2 + 3/4 * y ^ 4) (4/9 - (2 * x - 3 * x ^ 3)) x := by
      intro x _
      have h0 := ((HasDerivAt.const_mul (4/9 : ℝ) (hasDerivAt_id x)).sub
        (hasDerivAt_pow 2 x)).add ((hasDerivAt_pow 4 x).const_mul (3/4 : ℝ))
      simp only [id_eq] at h0
      convert h0 using 1
      push_cast; ring
    have hi1 : IntervalIntegrable (fun x : ℝ => 4/9 - (2 * x - 3 * x ^ 3))
        MeasureTheory.volume 0 a := by
      apply Continuous.intervalIntegrable; fun_prop
    have I1 := intervalIntegral.integral_eq_sub_of_hasDerivAt hd1 hi1
    have hd2 : ∀ x ∈ uIcc a (2/3 : ℝ),
        HasDerivAt (fun y : ℝ => y ^ 2 - 3/4 * y ^ 4 - 4/9 * y) (2 * x - 3 * x ^ 3 - 4/9) x := by
      intro x _
      have h0 := (((hasDerivAt_pow 2 x).sub ((hasDerivAt_pow 4 x).const_mul (3/4 : ℝ))).sub
        (HasDerivAt.const_mul (4/9 : ℝ) (hasDerivAt_id x)))
      simp only [id_eq] at h0
      convert h0 using 1
      push_cast; ring
    have hi2 : IntervalIntegrable (fun x : ℝ => 2 * x - 3 * x ^ 3 - 4/9)
        MeasureTheory.volume a (2/3) := by
      apply Continuous.intervalIntegrable; fun_prop
    have I2 := intervalIntegral.integral_eq_sub_of_hasDerivAt hd2 hi2
    rw [I1, I2]
    ring
