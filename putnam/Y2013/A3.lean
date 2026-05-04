import Mathlib

namespace Putnam2013A3

open scoped BigOperators

/-- Putnam 2013 A-3. Suppose `a_0, …, a_n ∈ ℝ` and `0 < x < 1` satisfy
`∑_{i=0}^n a_i / (1 − x^{i+1}) = 0`. Then there exists `y ∈ (0, 1)` with
`∑_{i=0}^n a_i y^i = 0`. -/
theorem putnam_2013_a3
    (n : ℕ) (a : ℕ → ℝ) (x : ℝ) (hx : x ∈ Set.Ioo (0 : ℝ) 1)
    (heq : ∑ i ∈ Finset.range (n + 1), a i / (1 - x ^ (i + 1)) = 0) :
    ∃ y ∈ Set.Ioo (0 : ℝ) 1, ∑ i ∈ Finset.range (n + 1), a i * y ^ i = 0 := by
  sorry

end Putnam2013A3
