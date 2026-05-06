import Mathlib

open Real MeasureTheory

noncomputable def putnam_1993_a1_solution : ℝ := 4/9

theorem putnam_1993_a1 :
    ∃ a b : ℝ, 0 < a ∧ a < b ∧
      2 * a - 3 * a ^ 3 = putnam_1993_a1_solution ∧
      2 * b - 3 * b ^ 3 = putnam_1993_a1_solution ∧
      (∫ x in (0 : ℝ)..a, (putnam_1993_a1_solution - (2 * x - 3 * x ^ 3))) =
        (∫ x in a..b, ((2 * x - 3 * x ^ 3) - putnam_1993_a1_solution)) := by
  refine ⟨(Real.sqrt 3 - 1) / 3, 2 / 3, ?_, ?_, ?_, ?_, ?_⟩
  · -- 0 < (√3 - 1)/3
    have h1 : (1 : ℝ) < Real.sqrt 3 := by
      have h : Real.sqrt 1 < Real.sqrt 3 :=
        Real.sqrt_lt_sqrt (by norm_num) (by norm_num)
      simpa using h
    linarith
  · -- (√3 - 1)/3 < 2/3
    have h3 : Real.sqrt 3 < 3 := by
      have h9 : Real.sqrt 9 = 3 := by
        rw [show (9 : ℝ) = 3^2 by norm_num]
        exact Real.sqrt_sq (by norm_num)
      have h : Real.sqrt 3 < Real.sqrt 9 :=
        Real.sqrt_lt_sqrt (by norm_num) (by norm_num)
      linarith
    linarith
  · -- 2 * ((√3 - 1)/3) - 3 * ((√3 - 1)/3)^3 = 4/9
    show 2 * ((Real.sqrt 3 - 1) / 3) - 3 * ((Real.sqrt 3 - 1) / 3) ^ 3 = putnam_1993_a1_solution
    unfold putnam_1993_a1_solution
    have hs : (Real.sqrt 3) ^ 2 = 3 := Real.sq_sqrt (by norm_num : (3:ℝ) ≥ 0)
    have hs3 : (Real.sqrt 3) ^ 3 = 3 * Real.sqrt 3 := by
      have : (Real.sqrt 3) ^ 3 = Real.sqrt 3 * (Real.sqrt 3) ^ 2 := by ring
      rw [this, hs]; ring
    set s := Real.sqrt 3
    have hs2 : s ^ 2 = 3 := hs
    have hs3' : s ^ 3 = 3 * s := hs3
    have expand : 2 * ((s - 1) / 3) - 3 * ((s - 1) / 3) ^ 3 =
        (2/3) * (s - 1) - (1/9) * (s - 1) ^ 3 := by ring
    rw [expand]
    have cube : (s - 1) ^ 3 = s ^ 3 - 3 * s ^ 2 + 3 * s - 1 := by ring
    rw [cube, hs2, hs3']
    ring
  · -- 2 * (2/3) - 3 * (2/3)^3 = 4/9
    show 2 * ((2:ℝ) / 3) - 3 * ((2:ℝ) / 3) ^ 3 = putnam_1993_a1_solution
    unfold putnam_1993_a1_solution
    norm_num
  · -- Integral equation
    set a := (Real.sqrt 3 - 1) / 3 with ha_def
    set b := (2 : ℝ) / 3 with hb_def
    set c := putnam_1993_a1_solution with hc_def
    -- Antiderivative F(y) = c*y - y^2 + (3/4)*y^4
    set F : ℝ → ℝ := fun y => c * y - y^2 + (3/4) * y^4 with hF_def
    have hF : ∀ x : ℝ, HasDerivAt F (c - (2 * x - 3 * x^3)) x := by
      intro x
      have h1 : HasDerivAt (fun y : ℝ => c * y) c x := by
        simpa using (hasDerivAt_id x).const_mul c
      have h2 : HasDerivAt (fun y : ℝ => y^2) (2 * x) x := by
        simpa using hasDerivAt_pow 2 x
      have h3 : HasDerivAt (fun y : ℝ => (3/4) * y^4) (3 * x^3) x := by
        have hh := (hasDerivAt_pow 4 x).const_mul (3/4 : ℝ)
        convert hh using 1
        ring
      have hsum := (h1.sub h2).add h3
      convert hsum using 1
      ring
    have hcont : Continuous (fun x : ℝ => c - (2 * x - 3 * x^3)) := by
      continuity
    have int1 : ∫ x in (0:ℝ)..a, (c - (2 * x - 3 * x^3)) = F a - F 0 := by
      apply intervalIntegral.integral_eq_sub_of_hasDerivAt
      · intro x _
        exact hF x
      · exact hcont.intervalIntegrable _ _
    have int2 : ∫ x in a..b, (c - (2 * x - 3 * x^3)) = F b - F a := by
      apply intervalIntegral.integral_eq_sub_of_hasDerivAt
      · intro x _
        exact hF x
      · exact hcont.intervalIntegrable _ _
    have flip : ∫ x in a..b, ((2 * x - 3 * x^3) - c) = -(∫ x in a..b, (c - (2 * x - 3 * x^3))) := by
      rw [← intervalIntegral.integral_neg]
      congr 1
      ext x
      ring
    rw [flip, int1, int2]
    -- F b = 0
    have hFb : F b = 0 := by
      simp only [hF_def, hc_def, hb_def, putnam_1993_a1_solution]
      norm_num
    have hF0 : F 0 = 0 := by
      simp only [hF_def]
      ring
    rw [hFb, hF0]
    ring
