import Mathlib

open Real BigOperators

noncomputable def putnam_2023_a1_solution : ℕ := 18

theorem putnam_2023_a1
    (f : ℕ → ℝ → ℝ)
    (hf : ∀ n x, f n x = ∏ k ∈ Finset.Icc 1 n, Real.cos (k * x)) :
    IsLeast {n : ℕ | 0 < n ∧ |iteratedDeriv 2 (f n) 0| > 2023} putnam_2023_a1_solution := by
  sorry
