import Mathlib

open scoped Real
open MeasureTheory

/-- Evaluate `∫_0^∞ t^(-1/2) e^(-1985 (t + t⁻¹)) dt`.

By the substitution `t = x²` this equals `2 ∫_0^∞ e^(-1985 (x² + x⁻²)) dx`, and
the classical Gaussian-type integral `∫_0^∞ e^(-a(x² + b²/x²)) dx = (1/2)√(π/a) e^(-2 b √a)`
(with `a = b = 1985`) gives the value `√(π/1985) · e^(-3970)`. -/
noncomputable def putnam_1985_b5_solution : ℝ :=
  Real.sqrt (Real.pi / 1985) * Real.exp (-3970)

theorem putnam_1985_b5 :
    (∫ t in Set.Ioi (0 : ℝ), t ^ (-(1 : ℝ) / 2) * Real.exp (-1985 * (t + t⁻¹)))
      = putnam_1985_b5_solution := by
  sorry
