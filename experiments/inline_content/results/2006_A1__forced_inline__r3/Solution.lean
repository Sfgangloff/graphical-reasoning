import Mathlib

open MeasureTheory

/-- The region is a torus (tube radius 1, centroid radius 3) obtained by revolving
the unit disk centered at distance 3 from the axis; its volume is `6 * π^2`. -/
noncomputable def putnam_2006_a1_solution : ℝ := 6 * Real.pi ^ 2

theorem putnam_2006_a1 :
    (volume {p : ℝ × ℝ × ℝ |
        (p.1 ^ 2 + p.2.1 ^ 2 + p.2.2 ^ 2 + 8) ^ 2 ≤ 36 * (p.1 ^ 2 + p.2.1 ^ 2)}).toReal
      = putnam_2006_a1_solution := by
  sorry
