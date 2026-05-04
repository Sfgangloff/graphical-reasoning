import Mathlib

namespace Putnam1988B4

/-- Putnam 1988 B-4. If `∑ aₙ` converges with all `aₙ > 0`, then so does
`∑ aₙ^{n/(n+1)}`. -/
theorem putnam_1988_b4 (a : ℕ+ → ℝ)
    (hpos : ∀ n, 0 < a n)
    (hconv : Summable a) :
    Summable (fun n : ℕ+ => (a n) ^ ((n : ℝ) / ((n : ℝ) + 1))) := by
  sorry

end Putnam1988B4
