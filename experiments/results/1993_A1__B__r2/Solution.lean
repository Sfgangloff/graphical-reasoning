import Mathlib

open MeasureTheory intervalIntegral

noncomputable def putnam_1993_a1_solution : ℝ := 4 / 9

/--
The horizontal line `y = c` intersects the curve `y = 2x - 3x^3` in the first
quadrant at two points `x₁ < x₂`. We seek `c` so that the two shaded regions have
equal area: the region bounded by the y-axis, the line `y = c`, and the curve
(area `∫₀^{x₁} (c - (2x - 3x³)) dx`), and the region under the curve and above
the line between the two intersections (area `∫_{x₁}^{x₂} ((2x - 3x³) - c) dx`).
-/
theorem putnam_1993_a1
    (c : ℝ) (hc : 0 < c ∧ c < 4 * Real.sqrt 2 / 9) :
    c = putnam_1993_a1_solution ↔
      ∃ x₁ x₂ : ℝ, 0 < x₁ ∧ x₁ < x₂ ∧
        2 * x₁ - 3 * x₁ ^ 3 = c ∧ 2 * x₂ - 3 * x₂ ^ 3 = c ∧
        ∫ x in (0 : ℝ)..x₁, (c - (2 * x - 3 * x ^ 3)) =
          ∫ x in x₁..x₂, ((2 * x - 3 * x ^ 3) - c) := by
  sorry
