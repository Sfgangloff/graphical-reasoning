import Mathlib

open Finset Real

/-- 1996 B2: for every positive integer `n`,
`((2n-1)/e)^((2n-1)/2) < 1·3·5···(2n-1) < ((2n+1)/e)^((2n+1)/2)`. -/
theorem putnam_1996_b2 (n : ℕ) (hn : 0 < n) :
    ((2 * (n : ℝ) - 1) / Real.exp 1) ^ ((2 * (n : ℝ) - 1) / 2)
        < ∏ k ∈ Finset.range n, (2 * (k : ℝ) + 1)
      ∧ ∏ k ∈ Finset.range n, (2 * (k : ℝ) + 1)
        < ((2 * (n : ℝ) + 1) / Real.exp 1) ^ ((2 * (n : ℝ) + 1) / 2) := by
  sorry
