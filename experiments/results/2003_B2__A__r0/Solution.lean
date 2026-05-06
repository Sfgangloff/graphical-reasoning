import Mathlib

open Finset Nat

theorem putnam_2003_b2
    (n : ℕ) (hn : 0 < n)
    (seq : ℕ → ℕ → ℝ)
    (hseq0 : ∀ i, i < n → seq 0 i = 1 / (i + 1))
    (hseqj : ∀ j i, j + 1 < n → i + j + 1 < n →
      seq (j + 1) i = (seq j i + seq j (i + 1)) / 2) :
    seq (n - 1) 0 < 2 / n := by
  sorry
