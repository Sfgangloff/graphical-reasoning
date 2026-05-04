import Mathlib

namespace Putnam1995A2

/-- The improper-integral convergence pairs are exactly those with `a = b`. -/
abbrev putnam_1995_a2_solution : Set (ℝ × ℝ) := {p | p.1 = p.2}

/-- Putnam 1995 A-2. For what pairs `(a, b)` of positive real numbers does
`∫_b^∞ (√(√(x+a) − √x) − √(√x − √(x−b))) dx` converge? Answer: `a = b`. -/
theorem putnam_1995_a2 :
    {p : ℝ × ℝ | 0 < p.1 ∧ 0 < p.2 ∧
      IntegrableOn (fun x : ℝ =>
          Real.sqrt (Real.sqrt (x + p.1) - Real.sqrt x) -
          Real.sqrt (Real.sqrt x - Real.sqrt (x - p.2)))
        (Set.Ioi p.2)} =
      {p : ℝ × ℝ | 0 < p.1 ∧ 0 < p.2 ∧ p ∈ putnam_1995_a2_solution} := by
  sorry

end Putnam1995A2
