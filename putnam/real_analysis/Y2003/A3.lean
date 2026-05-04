import Mathlib

namespace Putnam2003A3

/-- Putnam 2003 A-3. The minimum value of
`|sin x + cos x + tan x + cot x + sec x + csc x|`
over real `x` (where the expression is defined) is `2 √2 − 1`. -/
theorem putnam_2003_a3 :
    sInf {y : ℝ | ∃ x : ℝ,
      Real.cos x ≠ 0 ∧ Real.sin x ≠ 0 ∧
      y = |Real.sin x + Real.cos x + Real.tan x +
            (Real.cos x / Real.sin x) +
            (1 / Real.cos x) + (1 / Real.sin x)|} =
      2 * Real.sqrt 2 - 1 := by
  sorry

end Putnam2003A3
