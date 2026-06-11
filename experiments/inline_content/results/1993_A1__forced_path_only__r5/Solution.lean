import Mathlib

open intervalIntegral

noncomputable def putnam_1993_a1_solution : ℝ := 4 / 9

/-- The horizontal line `y = c` meets the curve `y = 2x - 3x^3` in the first quadrant.
Find `c` so that the area of the region bounded by the `y`-axis, the line and the curve
(between `0` and the first intersection `x1`) equals the area under the curve and above the
line (between the two intersections `x1` and `x2`). -/
theorem putnam_1993_a1 :
    0 < putnam_1993_a1_solution ∧ putnam_1993_a1_solution < 4 * Real.sqrt 2 / 9 ∧
    (∃ x1 x2 : ℝ, 0 < x1 ∧ x1 < x2 ∧
      2 * x1 - 3 * x1 ^ 3 = putnam_1993_a1_solution ∧
      2 * x2 - 3 * x2 ^ 3 = putnam_1993_a1_solution ∧
      (∫ x in (0:ℝ)..x1, (putnam_1993_a1_solution - (2 * x - 3 * x ^ 3)))
        = ∫ x in x1..x2, ((2 * x - 3 * x ^ 3) - putnam_1993_a1_solution)) := by
  sorry
