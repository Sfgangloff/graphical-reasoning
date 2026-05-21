import Mathlib

open MeasureTheory intervalIntegral

/-- Putnam 1993 A1.

The horizontal line `y = c` meets the curve `y = 2x - 3x^3` in the first
quadrant.  For `c` in the admissible range `(0, 4√2/9)` (the maximum of the
curve on the relevant branch is `4√2/9`), the line crosses the curve at two
positive points `a < b`.  The left region is bounded by the `y`-axis, the
line `y = c` and the curve (area `∫₀ᵃ (c - (2x - 3x³)) dx`); the right region
lies under the curve and above the line between the two intersection points
(area `∫ₐᵇ ((2x - 3x³) - c) dx`).  The two areas are equal exactly when
`c = 4/9`. -/
noncomputable def putnam_1993_a1_solution : ℝ := 4 / 9

theorem putnam_1993_a1 :
    putnam_1993_a1_solution ∈ Set.Ioo (0 : ℝ) (4 * Real.sqrt 2 / 9) ∧
      ∀ c ∈ Set.Ioo (0 : ℝ) (4 * Real.sqrt 2 / 9),
        ((∃ a b : ℝ, 0 < a ∧ a < b ∧
            2 * a - 3 * a ^ 3 = c ∧ 2 * b - 3 * b ^ 3 = c ∧
            (∫ x in (0 : ℝ)..a, (c - (2 * x - 3 * x ^ 3))) =
              ∫ x in a..b, ((2 * x - 3 * x ^ 3) - c))
          ↔ c = putnam_1993_a1_solution) := by
  have hsqrt2 : Real.sqrt 2 ^ 2 = 2 := Real.sq_sqrt (by norm_num)
  have hsqrt2nn : (0 : ℝ) ≤ Real.sqrt 2 := Real.sqrt_nonneg 2
  -- left antiderivative:  F t = c*t - t^2 + 3/4 * t^4,  F' t = c - (2t - 3t^3)
  -- right antiderivative: G t = t^2 - 3/4 * t^4 - c*t,  G' t = (2t - 3t^3) - c
  constructor
  · -- 4/9 ∈ (0, 4√2/9)
    refine ⟨by norm_num [putnam_1993_a1_solution], ?_⟩
    rw [putnam_1993_a1_solution]
    nlinarith [hsqrt2, hsqrt2nn]
  · intro c hc
    obtain ⟨hc0, hcmax⟩ := hc
    have key : ∀ p q : ℝ,
        (∫ x in p..q, (c - (2 * x - 3 * x ^ 3))) =
          (c * q - q ^ 2 + 3 / 4 * q ^ 4) - (c * p - p ^ 2 + 3 / 4 * p ^ 4) := by
      intro p q
      have hd : ∀ x ∈ Set.uIcc p q,
          HasDerivAt (fun t : ℝ => c * t - t ^ 2 + 3 / 4 * t ^ 4)
            (c - (2 * x - 3 * x ^ 3)) x := by
        intro x _
        have h := (((hasDerivAt_id x).const_mul c).sub
          (hasDerivAt_pow 2 x)).add ((hasDerivAt_pow 4 x).const_mul (3 / 4 : ℝ))
        convert h using 1
        push_cast
        ring
      have hint : IntervalIntegrable (fun x : ℝ => c - (2 * x - 3 * x ^ 3))
          MeasureTheory.volume p q := by
        apply Continuous.intervalIntegrable; fun_prop
      have := intervalIntegral.integral_eq_sub_of_hasDerivAt hd hint
      rw [this]
    have key2 : ∀ p q : ℝ,
        (∫ x in p..q, ((2 * x - 3 * x ^ 3) - c)) =
          (q ^ 2 - 3 / 4 * q ^ 4 - c * q) - (p ^ 2 - 3 / 4 * p ^ 4 - c * p) := by
      intro p q
      have hd : ∀ x ∈ Set.uIcc p q,
          HasDerivAt (fun t : ℝ => t ^ 2 - 3 / 4 * t ^ 4 - c * t)
            ((2 * x - 3 * x ^ 3) - c) x := by
        intro x _
        have h := (((hasDerivAt_pow 2 x).sub
          ((hasDerivAt_pow 4 x).const_mul (3 / 4 : ℝ))).sub
          ((hasDerivAt_id x).const_mul c))
        convert h using 1
        push_cast
        ring
      have hint : IntervalIntegrable (fun x : ℝ => (2 * x - 3 * x ^ 3) - c)
          MeasureTheory.volume p q := by
        apply Continuous.intervalIntegrable; fun_prop
      have := intervalIntegral.integral_eq_sub_of_hasDerivAt hd hint
      rw [this]
    constructor
    · rintro ⟨a, b, ha, hab, hca, hcb, hI⟩
      rw [key 0 a, key2 a b] at hI
      have hb0 : 0 < b := lt_trans ha hab
      -- the equal-area condition collapses to  c*b - b^2 + 3/4 b^4 = 0
      have star : c * b - b ^ 2 + 3 / 4 * b ^ 4 = 0 := by linear_combination hI
      have hstar' : b ^ 2 - 9 / 4 * b ^ 4 = 0 := by linear_combination star + b * hcb
      have hb2 : b ^ 2 = 4 / 9 := by
        nlinarith [hstar', mul_pos hb0 hb0, sq_nonneg b, hb0]
      have hcval : c = 4 / 9 := by
        nlinarith [hcb, hb2, hb0, sq_nonneg (b - 2 / 3), sq_nonneg (b + 2 / 3)]
      simpa [putnam_1993_a1_solution] using hcval
    · intro hcsol
      rw [putnam_1993_a1_solution] at hcsol
      subst hcsol
      have hs2 : Real.sqrt 3 ^ 2 = 3 := Real.sq_sqrt (by norm_num)
      have hsnn : (0 : ℝ) ≤ Real.sqrt 3 := Real.sqrt_nonneg 3
      have hs1 : 1 < Real.sqrt 3 := by nlinarith [hs2, hsnn]
      have hs3 : Real.sqrt 3 < 3 := by nlinarith [hs2, hsnn]
      set s := Real.sqrt 3 with hsdef
      refine ⟨(s - 1) / 3, 2 / 3, by linarith, by linarith, ?_, by norm_num, ?_⟩
      · linear_combination (-(s - 3) / 9) * hs2
      · rw [key 0 ((s - 1) / 3), key2 ((s - 1) / 3) (2 / 3)]
        ring
