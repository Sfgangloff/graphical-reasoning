import Mathlib

namespace Putnam1996B2

/-- Double factorial of odd numbers: `oddDoubleFact n = 1 · 3 · 5 ⋯ (2n−1)`. -/
def oddDoubleFact : ℕ → ℕ
  | 0 => 1
  | n + 1 => (2 * n + 1) * oddDoubleFact n

theorem putnam_1996_b2 (n : ℕ) (hn : 1 ≤ n) :
    ((2 * n - 1 : ℝ) / Real.exp 1) ^ ((2 * n - 1 : ℝ) / 2) <
      (oddDoubleFact n : ℝ) ∧
    (oddDoubleFact n : ℝ) <
      ((2 * n + 1 : ℝ) / Real.exp 1) ^ ((2 * n + 1 : ℝ) / 2) := by
  sorry

end Putnam1996B2
