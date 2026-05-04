import Mathlib

namespace Putnam1991A5

noncomputable abbrev putnam_1991_a5_solution : ℝ := 1 / 3

/-- Putnam 1991 A-5. Find the maximum of
`∫₀^y √(x⁴ + (y − y²)²) dx` over `0 ≤ y ≤ 1`. -/
theorem putnam_1991_a5 :
    IsGreatest
      ((fun y : ℝ => ∫ x in (0 : ℝ)..y,
          Real.sqrt (x ^ 4 + (y - y ^ 2) ^ 2)) ''
        Set.Icc (0 : ℝ) 1)
      putnam_1991_a5_solution := by
  sorry

end Putnam1991A5
