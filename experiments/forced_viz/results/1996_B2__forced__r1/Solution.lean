import Mathlib

open scoped BigOperators

/-- 1996 B2. For every positive integer `n`,
`((2n-1)/e)^((2n-1)/2) < 1·3·5···(2n-1) < ((2n+1)/e)^((2n+1)/2)`.
The product `1·3·5···(2n-1)` is written as `∏ i ∈ range n, (2 i + 1)`. -/
theorem putnam_1996_b2
    (n : ℕ) (npos : 0 < n)
    (prod1 : ℝ)
    (hprod1 : prod1 = ∏ i ∈ Finset.range n, (2 * (i : ℝ) + 1)) :
    ((2 * (n : ℝ) - 1) / Real.exp 1) ^ ((2 * (n : ℝ) - 1) / 2) < prod1 ∧
      prod1 < ((2 * (n : ℝ) + 1) / Real.exp 1) ^ ((2 * (n : ℝ) + 1) / 2) := by
  sorry
