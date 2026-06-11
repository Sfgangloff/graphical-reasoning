import Mathlib

open scoped Real

noncomputable def putnam_1993_a1_solution : ℝ := 4 / 9

/--
The horizontal line `y = c` meets the curve `y = 2x - 3x^3` in the first quadrant
at two points `x₁ < x₂`.  The region bounded by the `y`-axis, the line and the curve
has area `∫_0^{x₁} (c - (2x - 3x^3))`, and the region under the curve and above the
line between the two intersection points has area `∫_{x₁}^{x₂} ((2x - 3x^3) - c)`.
The unique value of `c` (between `0` and the maximum `4√2/9` of the curve) making the
two areas equal is `4/9`.
-/
theorem putnam_1993_a1 :
    putnam_1993_a1_solution ∈ Set.Ioo (0 : ℝ) (4 * Real.sqrt 2 / 9) ∧
    ∃! c : ℝ, c ∈ Set.Ioo (0 : ℝ) (4 * Real.sqrt 2 / 9) ∧
      ∃ x₁ x₂ : ℝ, 0 < x₁ ∧ x₁ < x₂ ∧
        2 * x₁ - 3 * x₁ ^ 3 = c ∧ 2 * x₂ - 3 * x₂ ^ 3 = c ∧
        (∫ x in (0 : ℝ)..x₁, (c - (2 * x - 3 * x ^ 3)))
          = (∫ x in x₁..x₂, ((2 * x - 3 * x ^ 3) - c)) := by
  -- Basic facts about square roots.
  have hs2 : (1 : ℝ) < Real.sqrt 2 := by
    rw [show (1 : ℝ) = Real.sqrt 1 from (Real.sqrt_one).symm]
    exact Real.sqrt_lt_sqrt (by norm_num) (by norm_num)
  have hsq3 : Real.sqrt 3 ^ 2 = 3 := Real.sq_sqrt (by norm_num)
  have hs3lt : Real.sqrt 3 < 3 := by nlinarith [hsq3, Real.sqrt_nonneg 3]
  have hs3gt : (1 : ℝ) < Real.sqrt 3 := by nlinarith [hsq3, Real.sqrt_nonneg 3]
  -- Antiderivative computation: ∫ (c - (2x - 3x³)) dx.
  have intpoly : ∀ (c a b : ℝ),
      (∫ x in a..b, (c - (2 * x - 3 * x ^ 3))) =
        (c * b - b ^ 2 + 3 / 4 * b ^ 4) - (c * a - a ^ 2 + 3 / 4 * a ^ 4) := by
    intro c a b
    have hderiv : ∀ x ∈ Set.uIcc a b,
        HasDerivAt (fun x : ℝ => c * x - x ^ 2 + 3 / 4 * x ^ 4)
          (c - (2 * x - 3 * x ^ 3)) x := by
      intro x _
      have e1 : HasDerivAt (fun x : ℝ => c * x) c x := by
        simpa using (hasDerivAt_id x).const_mul c
      have e2 : HasDerivAt (fun x : ℝ => x ^ 2) (2 * x) x := by
        have := hasDerivAt_pow 2 x
        convert this using 1
        norm_num
      have e3 : HasDerivAt (fun x : ℝ => 3 / 4 * x ^ 4) (3 * x ^ 3) x := by
        have := (hasDerivAt_pow 4 x).const_mul (3 / 4 : ℝ)
        convert this using 1
        norm_num
        ring
      have h := (e1.sub e2).add e3
      convert h using 1
      ring
    have hint : IntervalIntegrable (fun x : ℝ => c - (2 * x - 3 * x ^ 3))
        MeasureTheory.volume a b := by
      apply Continuous.intervalIntegrable
      fun_prop
    have := intervalIntegral.integral_eq_sub_of_hasDerivAt hderiv hint
    simpa using this
  -- ∫ ((2x - 3x³) - c) dx = - ∫ (c - (2x - 3x³)) dx.
  have intneg : ∀ (c a b : ℝ),
      (∫ x in a..b, ((2 * x - 3 * x ^ 3) - c)) =
        -(∫ x in a..b, (c - (2 * x - 3 * x ^ 3))) := by
    intro c a b
    rw [← intervalIntegral.integral_neg]
    exact intervalIntegral.integral_congr (fun x _ => by ring)
  constructor
  · -- 4/9 ∈ (0, 4√2/9)
    show putnam_1993_a1_solution ∈ Set.Ioo (0 : ℝ) (4 * Real.sqrt 2 / 9)
    rw [putnam_1993_a1_solution, Set.mem_Ioo]
    exact ⟨by norm_num, by linarith [hs2]⟩
  · -- uniqueness
    refine ⟨4 / 9, ⟨Set.mem_Ioo.mpr ⟨by norm_num, by linarith [hs2]⟩, ?_⟩, ?_⟩
    · -- existence of intersection points with equal areas
      refine ⟨(Real.sqrt 3 - 1) / 3, 2 / 3, by linarith [hs3gt], by linarith [hs3lt], ?_, ?_, ?_⟩
      · -- 2x₁ - 3x₁³ = 4/9
        linear_combination (-(Real.sqrt 3 - 3) / 9) * hsq3
      · -- 2x₂ - 3x₂³ = 4/9
        norm_num
      · -- equal areas
        rw [intpoly, intneg, intpoly]
        ring
    · -- uniqueness of c
      rintro c ⟨_, x₁, x₂, hx1pos, hx12, _, hf2, hint⟩
      rw [intpoly, intneg, intpoly] at hint
      have hx2pos : 0 < x₂ := lt_trans hx1pos hx12
      have h0 : c * x₂ - x₂ ^ 2 + 3 / 4 * x₂ ^ 4 = 0 := by linear_combination hint
      have h2 : x₂ ^ 2 - 9 / 4 * x₂ ^ 4 = 0 := by linear_combination h0 + x₂ * hf2
      have hx2sq : (0 : ℝ) < x₂ ^ 2 := by positivity
      have h3 : x₂ ^ 2 = 4 / 9 := by
        have hfac : x₂ ^ 2 * (1 - 9 / 4 * x₂ ^ 2) = 0 := by linear_combination h2
        rcases mul_eq_zero.mp hfac with h | h
        · exact absurd h (ne_of_gt hx2sq)
        · linarith
      have hx2 : x₂ = 2 / 3 := by
        have hfac : (x₂ - 2 / 3) * (x₂ + 2 / 3) = 0 := by linear_combination h3
        rcases mul_eq_zero.mp hfac with h | h
        · linarith
        · linarith
      rw [← hf2, hx2]; norm_num
