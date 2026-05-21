import Mathlib

open Real MeasureTheory Set

/-- 1985 B5. Evaluate `∫₀^∞ t^(-1/2) · e^(-1985 (t + t⁻¹)) dt`.

By the substitution `t = u²` and the classical Glasser identity one gets
`∫₀^∞ t^(-1/2) e^(-a (t + 1/t)) dt = √(π/a) · e^(-2a)`.  Here `a = 1985`,
so the value is `√(π/1985) · e^(-3970)`. -/
noncomputable def putnam_1985_b5_solution : ℝ :=
  Real.sqrt (Real.pi / 1985) * Real.exp (-3970)

theorem putnam_1985_b5 :
    (∫ t in Ioi (0 : ℝ), t ^ (-(1 : ℝ) / 2) * Real.exp (-1985 * (t + t⁻¹)))
      = putnam_1985_b5_solution := by
  sorry
