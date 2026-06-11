import Mathlib

open intervalIntegral MeasureTheory

noncomputable def putnam_1993_a1_solution : ℝ := 4 / 9

theorem putnam_1993_a1 :
    0 < putnam_1993_a1_solution ∧
    putnam_1993_a1_solution < 4 * Real.sqrt 2 / 9 ∧
    ∃ x₁ x₂ : ℝ, 0 < x₁ ∧ x₁ < x₂ ∧
      2 * x₁ - 3 * x₁ ^ 3 = putnam_1993_a1_solution ∧
      2 * x₂ - 3 * x₂ ^ 3 = putnam_1993_a1_solution ∧
      (∫ x in (0:ℝ)..x₁, (putnam_1993_a1_solution - (2 * x - 3 * x ^ 3)))
        = (∫ x in x₁..x₂, ((2 * x - 3 * x ^ 3) - putnam_1993_a1_solution)) := by
  unfold putnam_1993_a1_solution
  refine ⟨by norm_num, ?_, (Real.sqrt 3 - 1) / 3, 2 / 3, ?_, ?_, ?_, ?_, ?_⟩
  · -- 4/9 < 4√2/9
    have h2 : (1 : ℝ) < Real.sqrt 2 := by
      nlinarith [Real.sq_sqrt (by norm_num : (2:ℝ) ≥ 0), Real.sqrt_nonneg 2]
    nlinarith
  · -- 0 < (√3-1)/3
    have h3 : (1 : ℝ) < Real.sqrt 3 := by
      nlinarith [Real.sq_sqrt (by norm_num : (3:ℝ) ≥ 0), Real.sqrt_nonneg 3]
    linarith
  · -- (√3-1)/3 < 2/3
    have h3 : Real.sqrt 3 < 3 := by
      nlinarith [Real.sq_sqrt (by norm_num : (3:ℝ) ≥ 0), Real.sqrt_nonneg 3]
    linarith
  · -- 2*x₁ - 3*x₁^3 = 4/9
    have hs : Real.sqrt 3 ^ 2 = 3 := Real.sq_sqrt (by norm_num)
    nlinarith [hs, Real.sqrt_nonneg 3]
  · -- 2*x₂ - 3*x₂^3 = 4/9
    norm_num
  · -- integral equality
    set s := (Real.sqrt 3 - 1) / 3 with hs_def
    have hderiv : ∀ x : ℝ,
        HasDerivAt (fun y : ℝ => (4:ℝ)/9 * y - y ^ 2 + 3/4 * y ^ 4)
          ((4:ℝ)/9 - (2 * x - 3 * x ^ 3)) x := by
      intro x
      have h := (((hasDerivAt_id x).const_mul ((4:ℝ)/9)).sub
        (hasDerivAt_pow 2 x)).add ((hasDerivAt_pow 4 x).const_mul ((3:ℝ)/4))
      convert h using 1
      push_cast
      ring
    have hint1 : IntervalIntegrable
        (fun x : ℝ => (4:ℝ)/9 - (2 * x - 3 * x ^ 3)) volume 0 s :=
      (by fun_prop : Continuous (fun x : ℝ => (4:ℝ)/9 - (2 * x - 3 * x ^ 3))).intervalIntegrable _ _
    have hint2 : IntervalIntegrable
        (fun x : ℝ => (2 * x - 3 * x ^ 3) - (4:ℝ)/9) volume s (2/3) :=
      (by fun_prop : Continuous (fun x : ℝ => (2 * x - 3 * x ^ 3) - (4:ℝ)/9)).intervalIntegrable _ _
    have hL : (∫ x in (0:ℝ)..s, ((4:ℝ)/9 - (2 * x - 3 * x ^ 3)))
        = (fun y : ℝ => (4:ℝ)/9 * y - y ^ 2 + 3/4 * y ^ 4) s
          - (fun y : ℝ => (4:ℝ)/9 * y - y ^ 2 + 3/4 * y ^ 4) 0 :=
      intervalIntegral.integral_eq_sub_of_hasDerivAt (fun x _ => hderiv x) hint1
    have hderiv2 : ∀ x : ℝ,
        HasDerivAt (fun y : ℝ => -((4:ℝ)/9 * y - y ^ 2 + 3/4 * y ^ 4))
          ((2 * x - 3 * x ^ 3) - (4:ℝ)/9) x := by
      intro x
      have := (hderiv x).neg
      convert this using 1
      ring
    have hR : (∫ x in s..(2/3), ((2 * x - 3 * x ^ 3) - (4:ℝ)/9))
        = (fun y : ℝ => -((4:ℝ)/9 * y - y ^ 2 + 3/4 * y ^ 4)) (2/3)
          - (fun y : ℝ => -((4:ℝ)/9 * y - y ^ 2 + 3/4 * y ^ 4)) s :=
      intervalIntegral.integral_eq_sub_of_hasDerivAt (fun x _ => hderiv2 x) hint2
    rw [hL, hR]
    ring
