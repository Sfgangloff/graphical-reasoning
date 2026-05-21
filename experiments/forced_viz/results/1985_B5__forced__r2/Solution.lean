import Mathlib

open MeasureTheory Real Set

/-- The value of `∫_0^∞ t^{-1/2} e^{-1985(t + 1/t)} dt`.

General fact (Cauchy–Schlömilch / Gaussian substitution `t = u²`):
`∫_0^∞ t^{-1/2} e^{-a(t + 1/t)} dt = √(π/a) · e^{-2a}`.
With `a = 1985` this is `√(π/1985) · e^{-3970}`. -/
noncomputable def putnam_1985_b5_solution : ℝ :=
  Real.sqrt (Real.pi / 1985) * Real.exp (-3970)

theorem putnam_1985_b5 :
    ∫ t in Set.Ioi (0 : ℝ), t ^ (-(1 : ℝ) / 2) * Real.exp (-1985 * (t + t⁻¹))
      = putnam_1985_b5_solution := by
  sorry
