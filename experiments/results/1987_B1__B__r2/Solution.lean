import Mathlib

open Real MeasureTheory intervalIntegral

noncomputable def putnam_1987_b1_solution : ℝ := 1

theorem putnam_1987_b1 :
    ∫ x in (2:ℝ)..4,
      Real.sqrt (Real.log (9 - x)) /
        (Real.sqrt (Real.log (9 - x)) + Real.sqrt (Real.log (x + 3)))
      = putnam_1987_b1_solution := by
  sorry
