import Mathlib

namespace Putnam1988A3

abbrev putnam_1988_a3_solution : Set ℝ := Set.Ioi (1 / 2)

/-- Putnam 1988 A-3. Determine the set of real `x` for which
`∑_{n=1}^∞ ((1/n) · csc(1/n) − 1)^x` converges. -/
theorem putnam_1988_a3 (x : ℝ) :
    Summable (fun n : ℕ+ =>
        ((1 / (n : ℝ)) / Real.sin (1 / (n : ℝ)) - 1) ^ x)
      ↔ x ∈ putnam_1988_a3_solution := by
  sorry

end Putnam1988A3
