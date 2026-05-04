import Mathlib

namespace Putnam1987B1

noncomputable abbrev putnam_1987_b1_solution : ℝ := 1

/-- Putnam 1987 B-1. Evaluate
`∫₂^4 √(ln(9 - x)) / (√(ln(9 - x)) + √(ln(x + 3))) dx`. -/
theorem putnam_1987_b1 :
    ∫ x in (2 : ℝ)..4,
        Real.sqrt (Real.log (9 - x))
          / (Real.sqrt (Real.log (9 - x)) + Real.sqrt (Real.log (x + 3)))
      = putnam_1987_b1_solution := by
  sorry

end Putnam1987B1
