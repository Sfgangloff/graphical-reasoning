import Mathlib

open Real Set MeasureTheory

/-- The value of the integral `∫_0^∞ t^{-1/2} e^{-1985(t+t⁻¹)} dt`.
By the Cauchy–Schlömilch transformation, `∫_0^∞ t^{-1/2} e^{-a(t+t⁻¹)} dt = √(π/a) e^{-2a}`,
so for `a = 1985` the value is `√(π/1985) · e^{-3970}`. -/
noncomputable def putnam_1985_b5_solution : ℝ := Real.sqrt (Real.pi / 1985) * Real.exp (-3970)

theorem putnam_1985_b5 :
    ∫ t in Set.Ioi (0 : ℝ), t ^ (-(1 : ℝ) / 2) * Real.exp (-1985 * (t + t⁻¹))
      = putnam_1985_b5_solution := by
  sorry
