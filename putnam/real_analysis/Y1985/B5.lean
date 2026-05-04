import Mathlib

open MeasureTheory Set

namespace Putnam1985B5

noncomputable abbrev putnam_1985_b5_solution : ℝ :=
  Real.sqrt (Real.pi / 1985) * Real.exp (-3970)

/-- Putnam 1985 B-5. Evaluate `∫₀^∞ t^(-1/2) · e^(-1985(t + t⁻¹)) dt`. -/
theorem putnam_1985_b5 :
    ∫ t in Ioi (0 : ℝ), t ^ (-(1 : ℝ) / 2) * Real.exp (-1985 * (t + t⁻¹))
      = putnam_1985_b5_solution := by
  sorry

end Putnam1985B5
