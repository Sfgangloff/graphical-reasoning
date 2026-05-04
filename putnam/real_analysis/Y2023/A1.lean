import Mathlib

namespace Putnam2023A1

open scoped BigOperators

/-- Putnam 2023 A-1. For positive integer `n`, let
`f_n(x) = ∏_{k=1}^n cos(k x)`. The smallest `n` such that
`|f_n''(0)| > 2023` is `n = 18`. -/
theorem putnam_2023_a1
    (f : ℕ → ℝ → ℝ)
    (hf : ∀ n x, f n x = ∏ k ∈ Finset.Icc 1 n, Real.cos (k * x)) :
    IsLeast {n : ℕ | 0 < n ∧ |iteratedDeriv 2 (f n) 0| > 2023} 18 := by
  sorry

end Putnam2023A1
