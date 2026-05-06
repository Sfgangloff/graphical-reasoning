import Mathlib

open scoped BigOperators
open Finset

noncomputable def avgSeq : ℕ → ℕ → ℝ
  | 0, k => 1 / (k + 1 : ℝ)
  | i+1, k => (avgSeq i k + avgSeq i (k+1)) / 2

theorem putnam_2003_b2 (n : ℕ) (hn : 0 < n) : avgSeq (n-1) 0 < 2 / n := by
  sorry
