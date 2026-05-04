import Mathlib

namespace Putnam2016B1

/-- Putnam 2016 B-1. Let `x_0 = 1` and `x_{n+1} = ln(e^{x_n} − x_n)`
for `n ≥ 0`. The series `∑_{n=0}^∞ x_n` converges and equals
`e − 1`. -/
theorem putnam_2016_b1
    (x : ℕ → ℝ)
    (hx0 : x 0 = 1)
    (hx : ∀ n, x (n + 1) = Real.log (Real.exp (x n) - x n)) :
    HasSum x (Real.exp 1 - 1) := by
  sorry

end Putnam2016B1
