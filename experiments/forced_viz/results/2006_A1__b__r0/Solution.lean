import Mathlib

open MeasureTheory

noncomputable def putnam_2006_a1_solution : ℝ := 6 * Real.pi ^ 2

/--
Find the volume of the region of points $(x,y,z)$ such that
$(x^2 + y^2 + z^2 + 8)^2 \leq 36(x^2 + y^2)$.
-/
theorem putnam_2006_a1 :
    (volume {p : ℝ × ℝ × ℝ |
      (p.1 ^ 2 + p.2.1 ^ 2 + p.2.2 ^ 2 + 8) ^ 2 ≤ 36 * (p.1 ^ 2 + p.2.1 ^ 2)}).toReal
      = putnam_2006_a1_solution := by
  sorry
