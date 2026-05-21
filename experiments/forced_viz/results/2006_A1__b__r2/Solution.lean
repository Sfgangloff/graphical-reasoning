import Mathlib

open MeasureTheory

/-- The region is the solid torus obtained by rotating the unit disk
`(r-3)^2 + z^2 ≤ 1` about the `z`-axis; by Pappus its volume is
`2π·3·(π·1^2) = 6π²`. -/
noncomputable def putnam_2006_a1_solution : ℝ := 6 * Real.pi ^ 2

theorem putnam_2006_a1 :
    (volume {p : ℝ × ℝ × ℝ |
      (p.1 ^ 2 + p.2.1 ^ 2 + p.2.2 ^ 2 + 8) ^ 2 ≤ 36 * (p.1 ^ 2 + p.2.1 ^ 2)}).toReal
      = putnam_2006_a1_solution := by
  sorry
