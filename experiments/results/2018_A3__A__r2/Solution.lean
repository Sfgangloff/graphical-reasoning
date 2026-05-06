import Mathlib

open Real

noncomputable def putnam_2018_a3_solution : ℝ := 480 / 49

theorem putnam_2018_a3 :
    IsGreatest
      {y : ℝ | ∃ x : Fin 10 → ℝ, (∑ i, Real.cos (x i) = 0) ∧ y = ∑ i, Real.cos (3 * x i)}
      putnam_2018_a3_solution := by
  sorry
