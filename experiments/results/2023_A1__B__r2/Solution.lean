import Mathlib

open Real

abbrev putnam_2023_a1_solution : ℕ := 18

theorem putnam_2023_a1
    (f : ℕ → ℝ → ℝ)
    (hf : ∀ n > 0, ∀ x : ℝ, f n x = ∏ i ∈ Finset.Icc 1 n, Real.cos (i * x)) :
    IsLeast {n : ℕ | 0 < n ∧ |iteratedDeriv 2 (f n) 0| > 2023} putnam_2023_a1_solution := by
  sorry
