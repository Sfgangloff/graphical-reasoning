import Mathlib

open MeasureTheory Real Set

/-- Putnam 1985 B5.
Evaluate `∫_0^∞ t^{-1/2} e^{-1985 (t + t⁻¹)} dt`.

Using `t = u²` the integral equals `2 ∫_0^∞ e^{-1985 (u² + u⁻²)} du`, and with
`u² + u⁻² = (u - u⁻¹)² + 2` together with the Glasser substitution
`∫_0^∞ e^{-a(u - u⁻¹)²} du = (1/2)√(π/a)`, the value is `√(π/1985) · e^{-3970}`. -/
noncomputable def putnam_1985_b5_solution : ℝ :=
  Real.sqrt (Real.pi / 1985) * Real.exp (-3970)

theorem putnam_1985_b5 :
    ∫ t in Set.Ioi (0 : ℝ), t ^ (-(1 : ℝ) / 2) * Real.exp (-1985 * (t + t⁻¹))
      = putnam_1985_b5_solution := by
  sorry
