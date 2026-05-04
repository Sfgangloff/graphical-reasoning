import Mathlib

namespace Putnam2004A1

/-- Putnam 2004 A-1. Let `S : ℕ → ℕ` (the cumulative successful free
throws) satisfy `S(n+1) ∈ {S n, S n + 1}` for all `n`. If for some
`a < b` we have `S a < (4/5) a` and `S b > (4/5) b`, then there is
`n ∈ [a, b]` with `S n = (4/5) n`. -/
theorem putnam_2004_a1
    (S : ℕ → ℕ)
    (hstep : ∀ n, S (n + 1) = S n ∨ S (n + 1) = S n + 1)
    (a b : ℕ) (hab : a ≤ b)
    (hlt : (S a : ℝ) < (4 / 5) * a)
    (hgt : (S b : ℝ) > (4 / 5) * b) :
    ∃ n, a ≤ n ∧ n ≤ b ∧ (S n : ℝ) = (4 / 5) * n := by
  sorry

end Putnam2004A1
