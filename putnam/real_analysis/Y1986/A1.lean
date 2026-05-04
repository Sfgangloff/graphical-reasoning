import Mathlib

namespace Putnam1986A1

noncomputable abbrev putnam_1986_a1_solution : ℝ := 18

/-- Putnam 1986 A-1. Find the maximum value of `f(x) = x^3 - 3x` over
`{x : ℝ | x^4 + 36 ≤ 13 * x^2}`. -/
theorem putnam_1986_a1 :
    IsGreatest
      ((fun x : ℝ => x ^ 3 - 3 * x) '' {x : ℝ | x ^ 4 + 36 ≤ 13 * x ^ 2})
      putnam_1986_a1_solution := by
  sorry

end Putnam1986A1
