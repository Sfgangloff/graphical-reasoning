import Mathlib

namespace Putnam2010B1

/-- Putnam 2010 B-1. There is no infinite sequence `(a_n)` of reals
such that `∑_{i=1}^∞ a_i^m = m` for every positive integer `m`. -/
theorem putnam_2010_b1 :
    ¬ ∃ a : ℕ → ℝ,
      ∀ m : ℕ, 0 < m → HasSum (fun n => (a n) ^ m) (m : ℝ) := by
  sorry

end Putnam2010B1
