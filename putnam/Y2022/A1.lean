import Mathlib

namespace Putnam2022A1

/-- Putnam 2022 A-1. The set of `(a, b) ∈ ℝ²` such that the line
`y = a x + b` meets the curve `y = log(1 + x²)` in exactly one point
is `{(a, b) | a = 0 ∧ b ≠ 0} ∪ {(a, b) | a ≠ 0 ∧ ¬something}`.
Stated abstractly, characterize all such pairs. -/
theorem putnam_2022_a1 :
    ∃ S : Set (ℝ × ℝ), S = {p : ℝ × ℝ |
      ∃! x : ℝ, p.1 * x + p.2 = Real.log (1 + x ^ 2)} := by
  sorry

end Putnam2022A1
