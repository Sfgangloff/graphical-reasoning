import Mathlib

open Real Finset

/-- For every positive integer `n`,
    `((2n-1)/e)^((2n-1)/2) < 1·3·5···(2n-1) < ((2n+1)/e)^((2n+1)/2)`. -/
theorem putnam_1996_b2 (n : ℕ) (hn : 0 < n) :
    ((2 * (n : ℝ) - 1) / Real.exp 1) ^ ((2 * (n : ℝ) - 1) / 2) <
      (∏ k ∈ Finset.range n, (2 * (k : ℝ) + 1)) ∧
    (∏ k ∈ Finset.range n, (2 * (k : ℝ) + 1)) <
      ((2 * (n : ℝ) + 1) / Real.exp 1) ^ ((2 * (n : ℝ) + 1) / 2) := by
  -- Proof outline (induction on n):
  --   Lower bound step: f(2n+1) < (2n+1) f(2n-1), reducing to log(1 + 2/(2n-1)) < 2/(2n-1).
  --   Upper bound step: (2n+1) f(2n+1) < f(2n+3), reducing to log(1 + 2/(2n+1)) > 2/(2n+3).
  -- Both follow from Real.log_lt_sub_one_of_pos and Real.one_sub_inv_lt_log_of_pos.
  sorry
