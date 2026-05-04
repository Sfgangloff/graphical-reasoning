import Mathlib

namespace Putnam1993A1

noncomputable abbrev putnam_1993_a1_solution : ℝ := 4 / 9

/-- Putnam 1993 A-1. The horizontal line `y = c` cuts the curve `y = 2x - 3x^3`
in the first quadrant at two points `x₁ < x₂`. Find `c` so that the area of
the region bounded by the `y`-axis, the line `y = c`, and the curve (between
`x = 0` and `x = x₁`) equals the area of the region under the curve and above
`y = c` between `x = x₁` and `x = x₂`. -/
theorem putnam_1993_a1 :
    ∃ x₁ x₂ : ℝ, 0 < x₁ ∧ x₁ < x₂ ∧
      2 * x₁ - 3 * x₁ ^ 3 = putnam_1993_a1_solution ∧
      2 * x₂ - 3 * x₂ ^ 3 = putnam_1993_a1_solution ∧
      ∫ x in (0 : ℝ)..x₁, (putnam_1993_a1_solution - (2 * x - 3 * x ^ 3)) =
      ∫ x in x₁..x₂, ((2 * x - 3 * x ^ 3) - putnam_1993_a1_solution) := by
  sorry

end Putnam1993A1
