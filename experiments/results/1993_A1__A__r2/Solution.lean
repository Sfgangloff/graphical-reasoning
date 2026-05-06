import Mathlib

open Real intervalIntegral MeasureTheory

noncomputable abbrev putnam_1993_a1_solution : ℝ := 4/9

/--
1993 A1: Find $c$ so that the line $y=c$ cuts the curve $y = 2x - 3x^3$ into two
regions (in the first quadrant) of equal area.
-/
theorem putnam_1993_a1 :
    ∃ x₁ x₂ : ℝ, 0 < x₁ ∧ x₁ < x₂ ∧
      2 * x₁ - 3 * x₁^3 = putnam_1993_a1_solution ∧
      2 * x₂ - 3 * x₂^3 = putnam_1993_a1_solution ∧
      (∫ x in (0:ℝ)..x₁, (putnam_1993_a1_solution - (2*x - 3*x^3))) =
      (∫ x in x₁..x₂, ((2*x - 3*x^3) - putnam_1993_a1_solution)) := by
  refine ⟨(Real.sqrt 3 - 1)/3, 2/3, ?_, ?_, ?_, ?_, ?_⟩
  · -- 0 < (√3 - 1)/3
    have h3 : (1:ℝ) < Real.sqrt 3 := by
      have h1 : Real.sqrt 1 = 1 := Real.sqrt_one
      have hlt : Real.sqrt 1 < Real.sqrt 3 :=
        Real.sqrt_lt_sqrt (by norm_num) (by norm_num)
      linarith [hlt, h1]
    linarith
  · -- (√3 - 1)/3 < 2/3
    have h3 : Real.sqrt 3 < 3 := by
      have hsq : Real.sqrt 3 ^ 2 = 3 := Real.sq_sqrt (by norm_num : (3:ℝ) ≥ 0)
      have hpos : Real.sqrt 3 ≥ 0 := Real.sqrt_nonneg 3
      nlinarith [hsq, hpos]
    linarith
  · -- 2 * x₁ - 3 * x₁^3 = 4/9
    have hsq : Real.sqrt 3 ^ 2 = 3 := Real.sq_sqrt (by norm_num : (3:ℝ) ≥ 0)
    have hpos : Real.sqrt 3 ≥ 0 := Real.sqrt_nonneg 3
    show 2 * ((Real.sqrt 3 - 1)/3) - 3 * ((Real.sqrt 3 - 1)/3)^3 = 4/9
    have h3 : (Real.sqrt 3)^3 = 3 * Real.sqrt 3 := by
      have : (Real.sqrt 3)^3 = (Real.sqrt 3)^2 * Real.sqrt 3 := by ring
      rw [this, hsq]
    nlinarith [hsq, hpos, h3]
  · -- 2 * (2/3) - 3 * (2/3)^3 = 4/9
    show 2 * ((2:ℝ)/3) - 3 * ((2:ℝ)/3)^3 = 4/9
    norm_num
  · -- integrals equal: ∫₀^{x₁} (c - f) = ∫_{x₁}^{x₂} (f - c)
    -- We use that this is equivalent to ∫₀^{x₂} (c - f) = 0.
    set x₁ : ℝ := (Real.sqrt 3 - 1)/3
    set x₂ : ℝ := (2:ℝ)/3
    -- compute ∫ from a to b of (4/9 - (2x - 3x^3)) = 4/9 * (b-a) - (b^2 - a^2) + 3*(b^4 - a^4)/4
    have integral_formula : ∀ a b : ℝ,
        (∫ x in a..b, ((4/9 : ℝ) - (2*x - 3*x^3))) =
        (4/9) * (b - a) - (b^2 - a^2) + 3 * (b^4 - a^4) / 4 := by
      intros a b
      have hF : ∀ x : ℝ, HasDerivAt (fun y : ℝ => (4/9)*y - y^2 + 3*y^4/4)
          ((4/9) - (2*x - 3*x^3)) x := by
        intros x
        have h1 : HasDerivAt (fun y : ℝ => (4/9)*y) (4/9) x := by
          simpa using (hasDerivAt_id x).const_mul (4/9 : ℝ)
        have h2 : HasDerivAt (fun y : ℝ => y^2) (2*x) x := by
          have := (hasDerivAt_pow 2 x)
          simpa using this
        have h3 : HasDerivAt (fun y : ℝ => 3*y^4/4) (3*x^3) x := by
          have hp : HasDerivAt (fun y : ℝ => y^4) (4 * x^3) x := by
            have := (hasDerivAt_pow 4 x); simpa using this
          have := (hp.const_mul (3:ℝ)).div_const 4
          convert this using 1
          ring
        have := (h1.sub h2).add h3
        convert this using 1
        ring
      have heq := intervalIntegral.integral_eq_sub_of_hasDerivAt
        (f := fun y : ℝ => (4/9)*y - y^2 + 3*y^4/4)
        (f' := fun x : ℝ => (4/9) - (2*x - 3*x^3))
        (a := a) (b := b)
        (fun x _ => hF x)
        (Continuous.intervalIntegrable (by continuity) _ _)
      rw [heq]
      ring
    -- Want: ∫_{x₁}^{x₂} (f - c) = ∫₀^{x₁} (c - f)
    -- Use ∫_{x₁}^{x₂} (f - c) = -∫_{x₁}^{x₂} (c - f), and
    -- ∫₀^{x₁} (c - f) + ∫_{x₁}^{x₂} (c - f) = ∫₀^{x₂} (c - f)
    have h_sym : (∫ x in x₁..x₂, ((2*x - 3*x^3) - (4/9 : ℝ))) =
                 -(∫ x in x₁..x₂, ((4/9 : ℝ) - (2*x - 3*x^3))) := by
      rw [← intervalIntegral.integral_neg]
      congr 1; ext x; ring
    have h_split : (∫ x in (0:ℝ)..x₁, ((4/9 : ℝ) - (2*x - 3*x^3))) +
                   (∫ x in x₁..x₂, ((4/9 : ℝ) - (2*x - 3*x^3))) =
                   (∫ x in (0:ℝ)..x₂, ((4/9 : ℝ) - (2*x - 3*x^3))) := by
      apply intervalIntegral.integral_add_adjacent_intervals
      · exact Continuous.intervalIntegrable (by continuity) _ _
      · exact Continuous.intervalIntegrable (by continuity) _ _
    have h_total_zero : (∫ x in (0:ℝ)..x₂, ((4/9 : ℝ) - (2*x - 3*x^3))) = 0 := by
      rw [integral_formula]
      show (4/9) * (x₂ - 0) - (x₂^2 - 0^2) + 3 * (x₂^4 - 0^4) / 4 = 0
      simp only [x₂]
      norm_num
    show (∫ x in (0:ℝ)..x₁, ((4/9 : ℝ) - (2*x - 3*x^3))) =
         (∫ x in x₁..x₂, ((2*x - 3*x^3) - (4/9 : ℝ)))
    rw [h_sym]
    linarith [h_split, h_total_zero]
