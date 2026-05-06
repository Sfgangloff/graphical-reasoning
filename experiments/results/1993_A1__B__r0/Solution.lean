import Mathlib

open MeasureTheory intervalIntegral

noncomputable abbrev putnam_1993_a1_solution : ℝ := 4/9

theorem putnam_1993_a1 (c : ℝ) :
    (∃ x1 x2 : ℝ, 0 < x1 ∧ x1 < x2 ∧
      2*x1 - 3*x1^3 = c ∧ 2*x2 - 3*x2^3 = c ∧
      ∫ x in (0:ℝ)..x1, (c - (2*x - 3*x^3)) = ∫ x in x1..x2, ((2*x - 3*x^3) - c))
    ↔ c = putnam_1993_a1_solution := by
  -- Antiderivative G(x) = x^2 - 3x^4/4 - c*x has G'(x) = 2x - 3x^3 - c
  have hderiv : ∀ x : ℝ, HasDerivAt (fun y => y^2 - 3*y^4/4 - c*y) (2*x - 3*x^3 - c) x := by
    intro x
    have h1 : HasDerivAt (fun y : ℝ => y^2) (2*x) x := by
      simpa using hasDerivAt_pow 2 x
    have h2 : HasDerivAt (fun y : ℝ => y^4) (4*x^3) x := by
      simpa using hasDerivAt_pow 4 x
    have h3 : HasDerivAt (fun y : ℝ => 3*y^4/4) (3*x^3) x := by
      have hh : HasDerivAt (fun y : ℝ => 3*y^4/4) (3*(4*x^3)/4) x :=
        (h2.const_mul (3:ℝ)).div_const 4
      have heq : 3*(4*x^3)/4 = 3*x^3 := by ring
      rw [heq] at hh; exact hh
    have h4 : HasDerivAt (fun y : ℝ => c*y) c x := by
      simpa using (hasDerivAt_id x).const_mul c
    exact (h1.sub h3).sub h4
  -- Continuity of the integrand
  have hcont : Continuous (fun x : ℝ => 2*x - 3*x^3 - c) := by continuity
  -- Integral formula
  have hint : ∀ a b : ℝ, ∫ x in a..b, (2*x - 3*x^3 - c) =
              (b^2 - 3*b^4/4 - c*b) - (a^2 - 3*a^4/4 - c*a) := by
    intro a b
    exact intervalIntegral.integral_eq_sub_of_hasDerivAt (fun x _ => hderiv x)
      (hcont.intervalIntegrable _ _)
  constructor
  · rintro ⟨x1, x2, hx1, hx12, hc1, hc2, hint_eq⟩
    have hx2pos : 0 < x2 := lt_trans hx1 hx12
    -- Convert hint_eq to ∫_0^{x2} (f - c) = 0
    have e1 : ∫ x in (0:ℝ)..x1, (c - (2*x - 3*x^3)) =
              -∫ x in (0:ℝ)..x1, (2*x - 3*x^3 - c) := by
      rw [← intervalIntegral.integral_neg]
      congr 1; ext x; ring
    rw [e1] at hint_eq
    rw [hint 0 x1] at hint_eq
    rw [hint x1 x2] at hint_eq
    have hG : x2^2 - 3*x2^4/4 - c*x2 = 0 := by
      have h0 : (0:ℝ)^2 - 3*0^4/4 - c*0 = 0 := by ring
      linarith [hint_eq, h0]
    -- Substitute c = 2*x2 - 3*x2^3
    have hG' : x2^2 - 3*x2^4/4 - (2*x2 - 3*x2^3) * x2 = 0 := by
      rw [hc2]; linarith
    -- Simplify: -x2^2 + 9*x2^4/4 = 0, i.e., x2^2 * (9*x2^2 - 4) = 0
    have hpoly : x2^2 * (9*x2^2 - 4) = 0 := by nlinarith [hG']
    have hx2sq : 9*x2^2 - 4 = 0 := by
      rcases mul_eq_zero.mp hpoly with h | h
      · exfalso; nlinarith [sq_nonneg x2]
      · exact h
    have hx2val : x2 = 2/3 := by
      have : x2^2 = 4/9 := by linarith
      have hxp : x2 > 0 := hx2pos
      nlinarith [sq_nonneg (x2 - 2/3), sq_nonneg (x2 + 2/3), this]
    rw [hx2val] at hc2
    show c = 4/9
    linarith [hc2]
  · intro hc
    -- Use x1 = (sqrt 3 - 1)/3, x2 = 2/3
    refine ⟨(Real.sqrt 3 - 1)/3, 2/3, ?_, ?_, ?_, ?_, ?_⟩
    · have h3 : Real.sqrt 3 > 1 := by
        have : (1:ℝ) = Real.sqrt 1 := by simp
        rw [this]
        exact Real.sqrt_lt_sqrt (by norm_num) (by norm_num)
      linarith
    · have h3 : Real.sqrt 3 < 3 := by
        have : (3:ℝ) = Real.sqrt 9 := by
          rw [show (9:ℝ) = 3^2 by norm_num, Real.sqrt_sq (by norm_num : (3:ℝ) ≥ 0)]
        rw [this]
        exact Real.sqrt_lt_sqrt (by norm_num) (by norm_num)
      linarith
    · -- 2*x1 - 3*x1^3 = c
      have hsq : Real.sqrt 3 ^ 2 = 3 := Real.sq_sqrt (by norm_num : (3:ℝ) ≥ 0)
      have hcube : Real.sqrt 3 ^ 3 = 3 * Real.sqrt 3 := by
        have : Real.sqrt 3 ^ 3 = Real.sqrt 3 ^ 2 * Real.sqrt 3 := by ring
        rw [this, hsq]
      rw [hc]
      show 2 * ((Real.sqrt 3 - 1)/3) - 3 * ((Real.sqrt 3 - 1)/3)^3 = 4/9
      have expand : ((Real.sqrt 3 - 1)/3)^3 = (Real.sqrt 3 - 1)^3 / 27 := by ring
      have cube : (Real.sqrt 3 - 1)^3 = 6 * Real.sqrt 3 - 10 := by
        have : (Real.sqrt 3 - 1)^3 = Real.sqrt 3^3 - 3 * Real.sqrt 3^2 + 3 * Real.sqrt 3 - 1 := by ring
        rw [this, hsq, hcube]; ring
      rw [expand, cube]; ring
    · show 2*(2/3 : ℝ) - 3*(2/3)^3 = c
      rw [hc]; norm_num
    · -- Integral equality at c = 4/9, x1 = (√3-1)/3, x2 = 2/3
      -- Use the rephrasing: integral equality iff ∫_0^{x2}(f-c) = 0
      have e1 : ∫ x in (0:ℝ)..(Real.sqrt 3 - 1)/3, (c - (2*x - 3*x^3)) =
                -∫ x in (0:ℝ)..(Real.sqrt 3 - 1)/3, (2*x - 3*x^3 - c) := by
        rw [← intervalIntegral.integral_neg]
        congr 1; ext x; ring
      rw [e1]
      rw [hint 0 ((Real.sqrt 3 - 1)/3), hint ((Real.sqrt 3 - 1)/3) (2/3)]
      rw [hc]
      show -(((Real.sqrt 3 - 1)/3)^2 - 3*((Real.sqrt 3 - 1)/3)^4/4 - 4/9*((Real.sqrt 3 - 1)/3) -
            (0^2 - 3*0^4/4 - 4/9*0)) =
            (2/3)^2 - 3*(2/3)^4/4 - 4/9*(2/3) -
            (((Real.sqrt 3 - 1)/3)^2 - 3*((Real.sqrt 3 - 1)/3)^4/4 - 4/9*((Real.sqrt 3 - 1)/3))
      have hsq : Real.sqrt 3 ^ 2 = 3 := Real.sq_sqrt (by norm_num : (3:ℝ) ≥ 0)
      nlinarith [hsq, sq_nonneg (Real.sqrt 3)]
