import Mathlib

open Real MeasureTheory

/-- The value of `∫_0^∞ t^{-1/2} e^{-1985(t+t^{-1})} dt`, namely `√(π/1985) · e^{-3970}`. -/
noncomputable def putnam_1985_b5_solution : ℝ :=
  Real.sqrt (Real.pi / 1985) * Real.exp (-3970)

theorem putnam_1985_b5 :
    (∫ t in Set.Ioi (0 : ℝ), t ^ (-(1 : ℝ) / 2) * Real.exp (-1985 * (t + t⁻¹)))
      = putnam_1985_b5_solution := by
  sorry
