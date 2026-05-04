import Mathlib

namespace Putnam2002B3

/-- Putnam 2002 B-3. For all integers `n > 1`,
`1/(2 n e) < 1/e − (1 − 1/n)^n < 1/(n e)`. -/
theorem putnam_2002_b3
    (n : ℕ) (hn : 1 < n) :
    1 / (2 * n * Real.exp 1) < 1 / Real.exp 1 - (1 - 1 / n) ^ n ∧
      1 / Real.exp 1 - (1 - 1 / n) ^ n < 1 / (n * Real.exp 1) := by
  sorry

end Putnam2002B3
