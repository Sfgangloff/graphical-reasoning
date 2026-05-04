import Mathlib

namespace Putnam1993A2

/-- Putnam 1993 A-2. Let `(x_n)` be a sequence of nonzero reals with
`x_n^2 - x_{n-1} x_{n+1} = 1` for all `n ≥ 1`. Prove there exists `a : ℝ`
such that `x_{n+1} = a x_n - x_{n-1}` for all `n ≥ 1`. -/
theorem putnam_1993_a2 (x : ℕ → ℝ) (hxne : ∀ n, x n ≠ 0)
    (hx : ∀ n ≥ 1, (x n) ^ 2 - x (n - 1) * x (n + 1) = 1) :
    ∃ a : ℝ, ∀ n ≥ 1, x (n + 1) = a * x n - x (n - 1) := by
  sorry

end Putnam1993A2
