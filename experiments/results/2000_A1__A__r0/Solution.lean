import Mathlib

open scoped BigOperators

noncomputable abbrev putnam_2000_a1_solution : ℝ → Set ℝ := fun A => Set.Ioo 0 (A^2)

theorem putnam_2000_a1 (A : ℝ) (hA : A > 0) :
    {S : ℝ | ∃ x : ℕ → ℝ, (∀ j, x j > 0) ∧ HasSum x A ∧ HasSum (fun j => (x j)^2) S}
      = putnam_2000_a1_solution A := by
  sorry
