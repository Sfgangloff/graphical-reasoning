import Mathlib

open MeasureTheory Real

noncomputable def putnam_1985_b5_solution : ℝ := Real.sqrt (π / 1985) * Real.exp (-3970)

theorem putnam_1985_b5
    (fact : (∫ x : ℝ, Real.exp (-x ^ 2)) = Real.sqrt π) :
    (∫ t in Set.Ioi 0, t ^ ((-1 : ℝ) / 2) * Real.exp (-1985 * (t + t⁻¹)))
      = putnam_1985_b5_solution := by
  sorry
