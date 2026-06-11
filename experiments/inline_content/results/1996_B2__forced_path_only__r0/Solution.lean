import Mathlib

open Finset

/-- Putnam 1996 B2: For every positive integer `n`,
`((2n-1)/e)^((2n-1)/2) < 1·3·5···(2n-1) < ((2n+1)/e)^((2n+1)/2)`. -/
theorem putnam_1996_b2 (n : ℕ) (hn : 0 < n) :
    ((2 * (n : ℝ) - 1) / Real.exp 1) ^ ((2 * (n : ℝ) - 1) / 2) <
      ∏ i ∈ Finset.range n, (2 * (i : ℝ) + 1)
    ∧ (∏ i ∈ Finset.range n, (2 * (i : ℝ) + 1)) <
      ((2 * (n : ℝ) + 1) / Real.exp 1) ^ ((2 * (n : ℝ) + 1) / 2) := by
  sorry
