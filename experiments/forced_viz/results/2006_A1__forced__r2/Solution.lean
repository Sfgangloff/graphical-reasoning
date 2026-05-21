import Mathlib

open MeasureTheory

/-- Find the volume of the region of points `(x,y,z)` such that
`(x^2 + y^2 + z^2 + 8)^2 ≤ 36 (x^2 + y^2)`.

The region is a solid torus of revolution: writing `ρ = √(x²+y²)`, the
condition is equivalent to `(ρ - 3)² + z² ≤ 1`, a torus with major radius
`3` and minor radius `1`. By Pappus its volume is `2π·3·π·1² = 6π²`. -/
noncomputable def putnam_2006_a1_solution : ℝ := 6 * Real.pi ^ 2

theorem putnam_2006_a1 :
    (MeasureTheory.volume
      {p : ℝ × ℝ × ℝ |
        (p.1 ^ 2 + p.2.1 ^ 2 + p.2.2 ^ 2 + 8) ^ 2 ≤ 36 * (p.1 ^ 2 + p.2.1 ^ 2)}).toReal
      = putnam_2006_a1_solution := by
  sorry
