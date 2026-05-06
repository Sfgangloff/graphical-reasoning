import Mathlib

open Finset BigOperators

theorem putnam_2003_b2
    (n : ℕ) (hn : 1 ≤ n)
    (seq : ℕ → ℕ → ℝ)
    (hseq0 : ∀ i, i < n → seq 0 i = 1 / ((i : ℝ) + 1))
    (hseqsucc : ∀ k i, i + k + 1 < n → seq (k + 1) i = (seq k i + seq k (i + 1)) / 2) :
    seq (n - 1) 0 < 2 / (n : ℝ) := by
  sorry
