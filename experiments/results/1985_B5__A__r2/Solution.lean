import Mathlib

open MeasureTheory Set Real

noncomputable def putnam_1985_b5_solution : ℝ :=
  Real.sqrt (Real.pi / 1985) * Real.exp (-3970)

theorem putnam_1985_b5 :
    ∫ t in Ioi (0 : ℝ), t ^ (-(1 : ℝ) / 2) * Real.exp (-1985 * (t + 1 / t))
      = putnam_1985_b5_solution := by
  sorry
