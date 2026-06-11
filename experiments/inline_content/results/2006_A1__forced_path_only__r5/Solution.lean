import Mathlib

open MeasureTheory

/-- The volume of the region of points `(x, y, z)` with
`(x^2 + y^2 + z^2 + 8)^2 ≤ 36 (x^2 + y^2)` equals `6 π^2`. -/
noncomputable def putnam_2006_a1_solution : ℝ := 6 * Real.pi ^ 2

theorem putnam_2006_a1 :
    (volume {p : Fin 3 → ℝ |
      ((p 0) ^ 2 + (p 1) ^ 2 + (p 2) ^ 2 + 8) ^ 2 ≤ 36 * ((p 0) ^ 2 + (p 1) ^ 2)}).toReal
      = putnam_2006_a1_solution := by
  sorry
