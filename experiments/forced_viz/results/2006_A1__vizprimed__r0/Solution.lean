import Mathlib

open MeasureTheory

/-- Putnam 2006 A1.

The region `{(x,y,z) : (x²+y²+z²+8)² ≤ 36(x²+y²)}` is, in cylindrical
coordinates with `r² = x²+y²`, the condition `(r²+z²+8)² ≤ 36 r²`.
Both sides are nonnegative and `r ≥ 0`, so this is `r²+z²+8 ≤ 6r`,
i.e. `(r-3)² + z² ≤ 1`: a unit disk centered at `r = 3` revolved about
the `z`-axis.  By Pappus's theorem the volume is
`(π·1²)·(2π·3) = 6π²`. -/
noncomputable def putnam_2006_a1_solution : ℝ := 6 * Real.pi ^ 2

theorem putnam_2006_a1 :
    (MeasureTheory.volume
      {p : ℝ × ℝ × ℝ |
        (p.1 ^ 2 + p.2.1 ^ 2 + p.2.2 ^ 2 + 8) ^ 2 ≤ 36 * (p.1 ^ 2 + p.2.1 ^ 2)}).toReal
      = putnam_2006_a1_solution := by
  sorry
