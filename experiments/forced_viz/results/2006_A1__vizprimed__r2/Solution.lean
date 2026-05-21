import Mathlib

open MeasureTheory

noncomputable def putnam_2006_a1_solution : ℝ := 6 * Real.pi ^ 2

/-- 2006 A1: The region `(x²+y²+z²+8)² ≤ 36(x²+y²)` is the solid torus obtained
by revolving the unit disk centered at `(3,0)` in the `(r,z)`-half-plane about
the `z`-axis; its volume is `6π²`. -/
theorem putnam_2006_a1 :
    (volume {p : ℝ × ℝ × ℝ |
      (p.1 ^ 2 + p.2.1 ^ 2 + p.2.2 ^ 2 + 8) ^ 2 ≤ 36 * (p.1 ^ 2 + p.2.1 ^ 2)}).toReal
      = putnam_2006_a1_solution := by
  sorry
