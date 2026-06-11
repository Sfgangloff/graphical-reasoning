import Mathlib

open scoped Real
open MeasureTheory

/-- The value of `∫_0^∞ t^{-1/2} e^{-1985(t + t^{-1})} dt`. -/
noncomputable def putnam_1985_b5_solution : ℝ := Real.sqrt (π / 1985) * Real.exp (-3970)

theorem putnam_1985_b5 :
    (∫ t in Set.Ioi (0 : ℝ), t ^ (-(1 : ℝ) / 2) * Real.exp (-1985 * (t + t⁻¹)))
      = putnam_1985_b5_solution := by
  sorry
