import Mathlib

open Filter Topology

noncomputable abbrev putnam_1995_a5_solution : Prop := True

theorem putnam_1995_a5 :
    putnam_1995_a5_solution ↔
    ∀ (n : ℕ) (_ : 1 ≤ n) (a : Matrix (Fin n) (Fin n) ℝ) (x : Fin n → ℝ → ℝ),
      (∀ i j, 0 < a i j) →
      (∀ i, Differentiable ℝ (x i)) →
      (∀ i t, deriv (x i) t = ∑ j, a i j * x j t) →
      (∀ i, Tendsto (x i) atTop (𝓝 0)) →
      ¬ LinearIndependent ℝ x := by
  sorry
