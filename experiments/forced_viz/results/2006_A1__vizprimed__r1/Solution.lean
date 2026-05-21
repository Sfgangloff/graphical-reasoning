import Mathlib

open MeasureTheory

/-- The region `(x²+y²+z²+8)² ≤ 36(x²+y²)` is the solid torus obtained by
revolving the disc of radius `1` centred at distance `3` from the `z`-axis.
Its volume is `(2πR)(πr²) = 2π·3·π·1² = 6π²`. -/
noncomputable def putnam_2006_a1_solution : ℝ := 6 * Real.pi ^ 2

theorem putnam_2006_a1 :
    (MeasureTheory.volume
      {p : ℝ × ℝ × ℝ |
        (p.1 ^ 2 + p.2.1 ^ 2 + p.2.2 ^ 2 + 8) ^ 2
          ≤ 36 * (p.1 ^ 2 + p.2.1 ^ 2)}).toReal
      = putnam_2006_a1_solution := by
  sorry
