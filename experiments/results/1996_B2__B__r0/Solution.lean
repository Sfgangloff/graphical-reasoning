import Mathlib

open Real Finset

theorem putnam_1996_b2 (n : ℕ) (hn : 0 < n) :
    ((2*n-1 : ℝ)/Real.exp 1)^((2*n-1 : ℝ)/2) < ∏ k ∈ Finset.range n, (2*(k:ℝ)+1) ∧
    (∏ k ∈ Finset.range n, (2*(k:ℝ)+1)) < ((2*n+1 : ℝ)/Real.exp 1)^((2*n+1 : ℝ)/2) := by
  sorry
