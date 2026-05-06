import Mathlib

open Real

noncomputable def putnam_2023_a1_solution : ℕ := 18

theorem putnam_2023_a1 :
    IsLeast {n : ℕ | 0 < n ∧ |iteratedDeriv 2
      (fun x : ℝ => ∏ k ∈ Finset.Icc 1 n, Real.cos (k * x)) 0| > 2023}
    putnam_2023_a1_solution := by
  sorry
