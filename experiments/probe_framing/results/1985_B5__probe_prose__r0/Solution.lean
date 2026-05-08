import Mathlib

open MeasureTheory Real Set

noncomputable def putnam_1985_b5_solution : ℝ := Real.sqrt (Real.pi / 1985) * Real.exp (-3970)

theorem putnam_1985_b5 :
    ∫ t in Ioi (0:ℝ), t ^ (-(1:ℝ)/2) * Real.exp (-1985 * (t + t⁻¹)) = putnam_1985_b5_solution := by
  sorry
