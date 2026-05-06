import Mathlib

open MeasureTheory intervalIntegral

noncomputable def putnam_1993_a1_solution : ℝ := 4 / 9

/--
1993 A1.  The horizontal line `y = c` intersects the curve `y = 2x - 3x³`
in the first quadrant at two points `x₁ < x₂`.  The first shaded region is
bounded by the y-axis, the line `y = c` and the curve (for `0 ≤ x ≤ x₁`,
where the line lies above the curve).  The second shaded region lies under
the curve and above the line `y = c` between the two intersection points
(for `x₁ ≤ x ≤ x₂`).  We show that the two regions have equal area
precisely when `c = 4/9`.
-/
theorem putnam_1993_a1 :
    ∀ c : ℝ,
      (∃ x1 x2 : ℝ,
        0 < x1 ∧ x1 < x2 ∧
        2 * x1 - 3 * x1 ^ 3 = c ∧
        2 * x2 - 3 * x2 ^ 3 = c ∧
        (∫ x in (0:ℝ)..x1, (c - (2 * x - 3 * x ^ 3))) =
          (∫ x in x1..x2, ((2 * x - 3 * x ^ 3) - c)))
      ↔ c = putnam_1993_a1_solution := by
  sorry
