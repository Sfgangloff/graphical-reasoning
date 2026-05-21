import Mathlib

noncomputable def putnam_1993_a1_solution : ℝ := 4 / 9

theorem putnam_1993_a1 :
    0 < putnam_1993_a1_solution ∧
    putnam_1993_a1_solution < 4 * Real.sqrt 2 / 9 ∧
    ∃ x1 x2 : ℝ, (0 ≤ x1 ∧ x1 < x2) ∧
      2 * x1 - 3 * x1 ^ 3 = putnam_1993_a1_solution ∧
      2 * x2 - 3 * x2 ^ 3 = putnam_1993_a1_solution ∧
      (∫ x in (0:ℝ)..x1, (putnam_1993_a1_solution - (2 * x - 3 * x ^ 3)))
        = ∫ x in x1..x2, ((2 * x - 3 * x ^ 3) - putnam_1993_a1_solution) := by
  have hsol : putnam_1993_a1_solution = (4:ℝ)/9 := rfl
  -- antiderivative F with F' x = 4/9 - (2x - 3x^3)
  have hF : ∀ x : ℝ,
      HasDerivAt (fun y : ℝ => (4:ℝ)/9 * y - y ^ 2 + 3/4 * y ^ 4)
        ((4:ℝ)/9 - (2 * x - 3 * x ^ 3)) x := by
    intro x
    have h1 : HasDerivAt (fun y : ℝ => (4:ℝ)/9 * y) ((4:ℝ)/9) x := by
      simpa using (hasDerivAt_id x).const_mul ((4:ℝ)/9)
    have h2 : HasDerivAt (fun y : ℝ => y ^ 2) ((2:ℝ) * x) x := by
      simpa using hasDerivAt_pow 2 x
    have h3 : HasDerivAt (fun y : ℝ => (3:ℝ)/4 * y ^ 4) ((3:ℝ) * x ^ 3) x := by
      have := (hasDerivAt_pow 4 x).const_mul ((3:ℝ)/4)
      convert this using 1
      push_cast
      ring
    have hcomb := (h1.sub h2).add h3
    convert hcomb using 1
    ring
  set F : ℝ → ℝ := fun y : ℝ => (4:ℝ)/9 * y - y ^ 2 + 3/4 * y ^ 4 with hFdef
  have hs : Real.sqrt 3 ^ 2 = 3 := Real.sq_sqrt (by norm_num)
  have hsnn : (0:ℝ) ≤ Real.sqrt 3 := Real.sqrt_nonneg 3
  have hsge : (1:ℝ) ≤ Real.sqrt 3 := by nlinarith [hs, hsnn]
  refine ⟨by norm_num [hsol], ?_, ?_⟩
  · rw [hsol]
    nlinarith [Real.sq_sqrt (show (0:ℝ) ≤ 2 by norm_num), Real.sqrt_nonneg 2]
  refine ⟨(Real.sqrt 3 - 1)/3, 2/3, ⟨?_, ?_⟩, ?_, ?_, ?_⟩
  · nlinarith [hsge]
  · nlinarith [hs, hsnn, hsge]
  · rw [hsol]
    have hs3 : Real.sqrt 3 ^ 3 = 3 * Real.sqrt 3 := by
      have h : Real.sqrt 3 ^ 3 = Real.sqrt 3 ^ 2 * Real.sqrt 3 := by ring
      rw [h, hs]
    nlinarith [hs, hs3, hsnn]
  · rw [hsol]; norm_num
  · -- integral equality
    have hint1 : IntervalIntegrable (fun x : ℝ => (4:ℝ)/9 - (2 * x - 3 * x ^ 3))
        MeasureTheory.volume 0 ((Real.sqrt 3 - 1)/3) :=
      (by fun_prop : Continuous (fun x : ℝ => (4:ℝ)/9 - (2 * x - 3 * x ^ 3))).intervalIntegrable _ _
    have hint2 : IntervalIntegrable (fun x : ℝ => (2 * x - 3 * x ^ 3) - (4:ℝ)/9)
        MeasureTheory.volume ((Real.sqrt 3 - 1)/3) (2/3) :=
      (by fun_prop : Continuous (fun x : ℝ => (2 * x - 3 * x ^ 3) - (4:ℝ)/9)).intervalIntegrable _ _
    have e1 : (∫ x in (0:ℝ)..((Real.sqrt 3 - 1)/3),
                (putnam_1993_a1_solution - (2 * x - 3 * x ^ 3)))
              = F ((Real.sqrt 3 - 1)/3) - F 0 := by
      rw [hsol]
      exact intervalIntegral.integral_eq_sub_of_hasDerivAt (fun x _ => hF x) hint1
    have hG : ∀ x : ℝ,
        HasDerivAt (fun y : ℝ => - F y) ((2 * x - 3 * x ^ 3) - (4:ℝ)/9) x := by
      intro x
      have := (hF x).neg
      convert this using 1
      ring
    have e2 : (∫ x in ((Real.sqrt 3 - 1)/3)..(2/3),
                ((2 * x - 3 * x ^ 3) - putnam_1993_a1_solution))
              = (fun y => - F y) (2/3 : ℝ) - (fun y => - F y) ((Real.sqrt 3 - 1)/3) := by
      rw [hsol]
      exact intervalIntegral.integral_eq_sub_of_hasDerivAt (fun x _ => hG x) hint2
    rw [e1, e2]
    simp only [hFdef]
    norm_num
