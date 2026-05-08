import Mathlib

open Real

theorem putnam_1996_b2 (n : ℕ) (hn : 0 < n) :
    ((2 * (n : ℝ) - 1) / Real.exp 1) ^ ((2 * (n : ℝ) - 1) / 2) <
      (∏ k ∈ Finset.range n, ((2 * k + 1 : ℕ) : ℝ)) ∧
    (∏ k ∈ Finset.range n, ((2 * k + 1 : ℕ) : ℝ)) <
      ((2 * (n : ℝ) + 1) / Real.exp 1) ^ ((2 * (n : ℝ) + 1) / 2) := by
  sorry
