import Mathlib

open Real MeasureTheory

noncomputable def putnam_1991_a5_solution : ℝ := 1/3

theorem putnam_1991_a5 :
    IsGreatest
      {I : ℝ | ∃ y ∈ Set.Icc (0:ℝ) 1,
        I = ∫ x in (0:ℝ)..y, Real.sqrt (x^4 + (y - y^2)^2)}
      putnam_1991_a5_solution := by
  sorry
