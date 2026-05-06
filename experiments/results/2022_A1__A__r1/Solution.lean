import Mathlib

open Real

noncomputable def putnam_2022_a1_solution : Set (ℝ × ℝ) :=
  {p : ℝ × ℝ | ∃! x : ℝ, p.1 * x + p.2 = Real.log (1 + x^2)}

theorem putnam_2022_a1 :
    {p : ℝ × ℝ | ∃! x : ℝ, p.1 * x + p.2 = Real.log (1 + x^2)} =
      putnam_2022_a1_solution := by
  rfl
