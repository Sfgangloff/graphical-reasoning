import Mathlib

open MeasureTheory

/-- 2006 A1: The volume of the region of points `(x,y,z)` with
`(x² + y² + z² + 8)² ≤ 36(x² + y²)`.  The region is the solid torus obtained
by revolving the unit disk (radius 1) whose center is at distance 3 from the
z-axis, so by Pappus its volume is `π·1² · 2π·3 = 6π²`. -/
noncomputable def putnam_2006_a1_solution : ℝ := 6 * Real.pi ^ 2

theorem putnam_2006_a1 :
    (volume {p : ℝ × ℝ × ℝ |
      (p.1 ^ 2 + p.2.1 ^ 2 + p.2.2 ^ 2 + 8) ^ 2
        ≤ 36 * (p.1 ^ 2 + p.2.1 ^ 2)}).toReal
      = putnam_2006_a1_solution := by
  sorry
