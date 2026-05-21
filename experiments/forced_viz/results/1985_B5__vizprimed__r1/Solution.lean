import Mathlib

open MeasureTheory Set
open scoped Real

/-- Putnam 1985 B5.

Evaluate `∫_0^∞ t^{-1/2} e^{-1985 (t + t^{-1})} dt`.

The classical evaluation: with the substitution `t = x²` the integral becomes
`2 ∫_0^∞ e^{-1985 (x² + x^{-2})} dx`, and since `x² + x^{-2} = (x - x^{-1})² + 2`,
the Schlömilch / Glasser substitution gives
`∫_0^∞ e^{-1985 (x - x^{-1})²} dx = (1/2)·√(π/1985)`.
Hence the value is `√(π/1985) · e^{-3970}`. -/
noncomputable def putnam_1985_b5_solution : ℝ :=
  Real.sqrt (Real.pi / 1985) / Real.exp 3970

theorem putnam_1985_b5 :
    (∫ t in Set.Ioi (0 : ℝ),
        t ^ (-(1 : ℝ) / 2) * Real.exp (-1985 * (t + t⁻¹)))
      = putnam_1985_b5_solution := by
  sorry
