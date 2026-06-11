import Mathlib

open MeasureTheory

noncomputable def putnam_1993_a1_solution : ℝ := 4 / 9

theorem putnam_1993_a1 :
    ∃ b d : ℝ, 0 < b ∧ b < d ∧
      (2 * b - 3 * b ^ 3 = putnam_1993_a1_solution) ∧
      (2 * d - 3 * d ^ 3 = putnam_1993_a1_solution) ∧
      (∫ x in (0:ℝ)..b, (putnam_1993_a1_solution - (2 * x - 3 * x ^ 3))) =
        (∫ x in b..d, ((2 * x - 3 * x ^ 3) - putnam_1993_a1_solution)) := by
  have hc : putnam_1993_a1_solution = 4 / 9 := rfl
  have hs : Real.sqrt 3 ^ 2 = 3 := Real.sq_sqrt (by norm_num)
  have hsnn : (0:ℝ) ≤ Real.sqrt 3 := Real.sqrt_nonneg 3
  have hs1 : (1:ℝ) < Real.sqrt 3 := by nlinarith [hs, hsnn]
  have hs2 : Real.sqrt 3 < 2 := by nlinarith [hs, hsnn]
  set b : ℝ := (Real.sqrt 3 - 1) / 3 with hb
  refine ⟨b, 2 / 3, ?_, ?_, ?_, ?_, ?_⟩
  · rw [hb]; exact div_pos (by linarith) (by norm_num)
  · rw [hb]; linarith
  · rw [hc, hb]; linear_combination ((3 - Real.sqrt 3) / 9) * hs
  · rw [hc]; norm_num
  · rw [hc]
    -- antiderivative G y = (4/9) y - y^2 + (3/4) y^4
    have hG : ∀ x : ℝ,
        HasDerivAt (fun y : ℝ => (4/9:ℝ) * y - y ^ 2 + (3/4) * y ^ 4)
          ((4/9:ℝ) - (2 * x - 3 * x ^ 3)) x := by
      intro x
      have h1 : HasDerivAt (fun y : ℝ => (4/9:ℝ) * y) (4/9) x := by
        simpa using (hasDerivAt_id x).const_mul (4/9 : ℝ)
      have h2 : HasDerivAt (fun y : ℝ => y ^ 2) ((2:ℝ) * x ^ (2 - 1)) x := hasDerivAt_pow 2 x
      have h3 : HasDerivAt (fun y : ℝ => (3/4:ℝ) * y ^ 4) ((3/4) * ((4:ℝ) * x ^ (4 - 1))) x :=
        (hasDerivAt_pow 4 x).const_mul (3/4 : ℝ)
      have h := (h1.sub h2).add h3
      convert h using 1
      push_cast
      ring
    have hG' : ∀ x : ℝ,
        HasDerivAt (fun y : ℝ => -((4/9:ℝ) * y - y ^ 2 + (3/4) * y ^ 4))
          ((2 * x - 3 * x ^ 3) - (4/9:ℝ)) x := by
      intro x
      have h := (hG x).neg
      convert h using 1
      ring
    have cont1 : Continuous (fun x : ℝ => (4/9:ℝ) - (2 * x - 3 * x ^ 3)) := by fun_prop
    have cont2 : Continuous (fun x : ℝ => (2 * x - 3 * x ^ 3) - (4/9:ℝ)) := by fun_prop
    have int1 := intervalIntegral.integral_eq_sub_of_hasDerivAt
      (f := fun y : ℝ => (4/9:ℝ) * y - y ^ 2 + (3/4) * y ^ 4)
      (f' := fun x : ℝ => (4/9:ℝ) - (2 * x - 3 * x ^ 3))
      (a := 0) (b := b) (fun x _ => hG x) (cont1.intervalIntegrable _ _)
    have int2 := intervalIntegral.integral_eq_sub_of_hasDerivAt
      (f := fun y : ℝ => -((4/9:ℝ) * y - y ^ 2 + (3/4) * y ^ 4))
      (f' := fun x : ℝ => (2 * x - 3 * x ^ 3) - (4/9:ℝ))
      (a := b) (b := 2/3) (fun x _ => hG' x) (cont2.intervalIntegrable _ _)
    rw [int1, int2]
    ring
