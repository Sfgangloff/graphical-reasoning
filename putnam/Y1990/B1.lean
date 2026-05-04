import Mathlib

namespace Putnam1990B1

noncomputable abbrev putnam_1990_b1_solution : Set (ℝ → ℝ) :=
  {fun x => Real.sqrt 1990 * Real.exp x,
   fun x => -Real.sqrt 1990 * Real.exp x}

/-- Putnam 1990 B-1. Find all `f ∈ C¹(ℝ, ℝ)` such that
`(f x)² = ∫₀^x ((f t)² + (f' t)²) dt + 1990` for all real `x`. -/
theorem putnam_1990_b1 (f : ℝ → ℝ) :
    (ContDiff ℝ 1 f ∧
        ∀ x, (f x) ^ 2
          = (∫ t in (0 : ℝ)..x, (f t) ^ 2 + (deriv f t) ^ 2) + 1990)
      ↔ f ∈ putnam_1990_b1_solution := by
  sorry

end Putnam1990B1
