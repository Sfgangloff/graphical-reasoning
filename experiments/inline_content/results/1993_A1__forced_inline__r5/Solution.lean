import Mathlib

open MeasureTheory

noncomputable def putnam_1993_a1_solution : ℝ := 4 / 9

/-- The horizontal line `y = c` meets the curve `y = 2x - 3x³` at two points
`x₁ < x₂` in the first quadrant. The area of the region bounded by the `y`-axis,
the line and the curve (`∫₀^{x₁} (c - (2x-3x³))`) equals the area of the region
under the curve and above the line (`∫_{x₁}^{x₂} ((2x-3x³) - c)`).
We must find `c`; the answer is `4/9`. -/
theorem putnam_1993_a1
    (c : ℝ)
    (h : ∃ x₁ x₂ : ℝ, 0 < x₁ ∧ x₁ < x₂ ∧
      2 * x₁ - 3 * x₁ ^ 3 = c ∧ 2 * x₂ - 3 * x₂ ^ 3 = c ∧
      (∫ x in (0 : ℝ)..x₁, (c - (2 * x - 3 * x ^ 3))) =
        ∫ x in x₁..x₂, ((2 * x - 3 * x ^ 3) - c)) :
    c = putnam_1993_a1_solution := by
  obtain ⟨x₁, x₂, hx1, hx12, _hf1, hf2, harea⟩ := h
  have hx2pos : 0 < x₂ := lt_trans hx1 hx12
  -- the integrand `g x = c - (2x - 3x³)` is continuous, hence integrable
  have cont : Continuous (fun x : ℝ => c - (2 * x - 3 * x ^ 3)) := by fun_prop
  have ii1 : IntervalIntegrable (fun x : ℝ => c - (2 * x - 3 * x ^ 3)) volume 0 x₁ :=
    cont.intervalIntegrable _ _
  have ii2 : IntervalIntegrable (fun x : ℝ => c - (2 * x - 3 * x ^ 3)) volume x₁ x₂ :=
    cont.intervalIntegrable _ _
  -- the second region's integrand is the negative of `g`
  have hneg : (∫ x in x₁..x₂, ((2 * x - 3 * x ^ 3) - c)) =
      -∫ x in x₁..x₂, (c - (2 * x - 3 * x ^ 3)) := by
    rw [← intervalIntegral.integral_neg]
    congr 1; funext x; ring
  -- combining the two adjacent integrals gives `∫₀^{x₂} g = 0`
  have hsum : (∫ x in (0 : ℝ)..x₂, (c - (2 * x - 3 * x ^ 3))) = 0 := by
    rw [← intervalIntegral.integral_add_adjacent_intervals ii1 ii2]
    rw [hneg] at harea
    linarith [harea]
  -- evaluate `∫₀^{x₂} g` via the fundamental theorem of calculus
  have hderiv : ∀ x : ℝ, HasDerivAt (fun y : ℝ => c * y - y ^ 2 + (3 / 4) * y ^ 4)
      (c - (2 * x - 3 * x ^ 3)) x := by
    intro x
    have e1 : HasDerivAt (fun y : ℝ => c * y) c x := by
      simpa using (hasDerivAt_id x).const_mul c
    have e2 : HasDerivAt (fun y : ℝ => y ^ 2) (2 * x) x := by
      simpa using hasDerivAt_pow 2 x
    have e3 : HasDerivAt (fun y : ℝ => (3 / 4) * y ^ 4) ((3 / 4) * (4 * x ^ 3)) x := by
      simpa using (hasDerivAt_pow 4 x).const_mul (3 / 4)
    have hd := (e1.sub e2).add e3
    have hval : (c - (2 * x - 3 * x ^ 3)) = c - 2 * x + (3 / 4) * (4 * x ^ 3) := by ring
    rw [hval]
    exact hd
  have hFTC : (∫ x in (0 : ℝ)..x₂, (c - (2 * x - 3 * x ^ 3))) =
      (c * x₂ - x₂ ^ 2 + (3 / 4) * x₂ ^ 4) - (c * 0 - 0 ^ 2 + (3 / 4) * 0 ^ 4) :=
    intervalIntegral.integral_eq_sub_of_hasDerivAt (fun x _ => hderiv x)
      (cont.intervalIntegrable _ _)
  rw [hFTC] at hsum
  -- algebra: eliminate c and solve for x₂
  have key : x₂ ^ 2 * (4 - 9 * x₂ ^ 2) = 0 := by
    linear_combination 4 * hsum + 4 * x₂ * hf2
  have hsq : x₂ ^ 2 = 4 / 9 := by
    have hx2sq : 0 < x₂ ^ 2 := by positivity
    rcases mul_eq_zero.mp key with h' | h'
    · exact absurd h' (ne_of_gt hx2sq)
    · linarith
  have hx2 : x₂ = 2 / 3 := by
    have factored : (x₂ - 2 / 3) * (x₂ + 2 / 3) = 0 := by linear_combination hsq
    rcases mul_eq_zero.mp factored with h' | h'
    · linarith
    · linarith
  show c = (4 / 9 : ℝ)
  rw [← hf2, hx2]; norm_num
