import Mathlib

open intervalIntegral

noncomputable def putnam_1993_a1_solution : ℝ := 4 / 9

theorem putnam_1993_a1 :
    ∃ a b : ℝ,
      0 < a ∧ a < b ∧
      2 * a - 3 * a ^ 3 = putnam_1993_a1_solution ∧
      2 * b - 3 * b ^ 3 = putnam_1993_a1_solution ∧
      (∫ x in (0:ℝ)..a, (putnam_1993_a1_solution - (2 * x - 3 * x ^ 3)))
        = (∫ x in a..b, ((2 * x - 3 * x ^ 3) - putnam_1993_a1_solution)) := by
  set s := Real.sqrt 3 with hsdef
  have hs2 : s ^ 2 = 3 := Real.sq_sqrt (by norm_num)
  have hsnn : 0 ≤ s := Real.sqrt_nonneg 3
  have hs3 : s ^ 3 = 3 * s := by
    have : s ^ 3 = s ^ 2 * s := by ring
    rw [this, hs2]
  refine ⟨(s - 1) / 3, 2 / 3, ?_, ?_, ?_, ?_, ?_⟩
  · -- 0 < (s - 1)/3
    have : 1 < s := by nlinarith [hs2, hsnn, sq_nonneg (s - 1)]
    linarith
  · -- (s - 1)/3 < 2/3
    have : s < 2 := by nlinarith [hs2, hsnn, sq_nonneg (s - 2)]
    linarith
  · -- 2 a - 3 a^3 = 4/9
    show 2 * ((s - 1) / 3) - 3 * ((s - 1) / 3) ^ 3 = putnam_1993_a1_solution
    unfold putnam_1993_a1_solution
    linear_combination (1/3) * hs2 - (1/9) * hs3
  · -- 2 b - 3 b^3 = 4/9
    show 2 * ((2:ℝ) / 3) - 3 * ((2:ℝ) / 3) ^ 3 = putnam_1993_a1_solution
    unfold putnam_1993_a1_solution
    norm_num
  · -- integral equality
    unfold putnam_1993_a1_solution
    set F : ℝ → ℝ := fun x => (4/9) * x - x ^ 2 + (3/4) * x ^ 4 with hFdef
    have hderiv : ∀ x : ℝ, HasDerivAt F (4/9 - (2 * x - 3 * x ^ 3)) x := by
      intro x
      have h := (((hasDerivAt_id x).const_mul (4/9 : ℝ)).sub
        (hasDerivAt_pow 2 x)).add ((hasDerivAt_pow 4 x).const_mul (3/4 : ℝ))
      simp only [hFdef]
      convert h using 1
      push_cast
      ring
    have hI1 : (∫ x in (0:ℝ)..((s - 1)/3), (4/9 - (2 * x - 3 * x ^ 3)))
        = F ((s - 1)/3) - F 0 := by
      rw [intervalIntegral.integral_eq_sub_of_hasDerivAt
        (fun x _ => hderiv x)]
      exact (Continuous.intervalIntegrable (by fun_prop) _ _)
    have hI2 : (∫ x in ((s - 1)/3)..(2/3), ((2 * x - 3 * x ^ 3) - 4/9))
        = (-F (2/3)) - (-F ((s - 1)/3)) := by
      have hderiv2 : ∀ x : ℝ, HasDerivAt (fun y => -F y)
          ((2 * x - 3 * x ^ 3) - 4/9) x := by
        intro x
        have := (hderiv x).neg
        convert this using 1
        ring
      rw [intervalIntegral.integral_eq_sub_of_hasDerivAt
        (fun x _ => hderiv2 x)]
      exact (Continuous.intervalIntegrable (by fun_prop) _ _)
    rw [hI1, hI2]
    have hF0 : F 0 = 0 := by simp [hFdef]
    have hFb : F (2/3) = 0 := by rw [hFdef]; norm_num
    rw [hF0, hFb]
    ring
