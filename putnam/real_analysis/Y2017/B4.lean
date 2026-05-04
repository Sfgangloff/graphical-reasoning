import Mathlib

namespace Putnam2017B4

/-- Putnam 2017 B-4. Evaluate
`∑_{k=0}^∞ (3 ln(4k+2)/(4k+2) − ln(4k+3)/(4k+3) − ln(4k+4)/(4k+4) − ln(4k+5)/(4k+5))`.
The value is `(ln 2)² / 2`. -/
theorem putnam_2017_b4 :
    HasSum (fun k : ℕ =>
        3 * Real.log (4 * k + 2) / (4 * k + 2) -
          Real.log (4 * k + 3) / (4 * k + 3) -
          Real.log (4 * k + 4) / (4 * k + 4) -
          Real.log (4 * k + 5) / (4 * k + 5))
      ((Real.log 2) ^ 2 / 2) := by
  sorry

end Putnam2017B4
