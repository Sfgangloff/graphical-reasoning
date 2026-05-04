import Mathlib

namespace Putnam1996B2

/-- Double factorial of odd numbers: `oddDoubleFact n = 1 · 3 · 5 ⋯ (2n−1)`. -/
def oddDoubleFact : ℕ → ℕ
  | 0 => 1
  | n + 1 => (2 * n + 1) * oddDoubleFact n

/-- Putnam 1996 B-2. For every positive integer `n`,
`((2n−1)/e)^((2n−1)/2) < 1·3·5⋯(2n−1) < ((2n+1)/e)^((2n+1)/2)`. -/
theorem putnam_1996_b2 (n : ℕ) (hn : 1 ≤ n) :
    ((2 * n - 1 : ℝ) / Real.exp 1) ^ ((2 * n - 1 : ℝ) / 2) <
      (oddDoubleFact n : ℝ) ∧
    (oddDoubleFact n : ℝ) <
      ((2 * n + 1 : ℝ) / Real.exp 1) ^ ((2 * n + 1 : ℝ) / 2) := by
  sorry

end Putnam1996B2
