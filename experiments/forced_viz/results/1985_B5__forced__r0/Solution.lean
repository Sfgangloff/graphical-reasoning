import Mathlib

open MeasureTheory Real Set

/-- Putnam 1985 B5.

Evaluate `∫₀^∞ t^(−1/2) · e^(−1985 (t + t⁻¹)) dt`.

By the substitution `t = u²` followed by the Cauchy–Schlömilch transformation
one obtains the closed form `√(π/1985) · e^(−3970)`. -/
noncomputable def putnam_1985_b5_solution : ℝ :=
  Real.sqrt (Real.pi / 1985) * Real.exp (-3970)

theorem putnam_1985_b5 :
    (∫ t in Set.Ioi (0 : ℝ),
        t ^ (-(1 : ℝ) / 2) * Real.exp (-1985 * (t + t⁻¹)))
      = putnam_1985_b5_solution := by
  sorry
