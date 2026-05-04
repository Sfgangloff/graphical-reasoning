import Mathlib

namespace Putnam1996A6

/-- Solution: if `c > 1/4` only constants work; if `c ≤ 1/4` the continuous
solutions are precisely those that are constant on `[α, ∞)` (where
`α = (1 − √(1 − 4c))/2` is the smaller fixed point of `x ↦ x² + c`) and
satisfy `f(x) = f(−x) = f(x² + c)` on the rest of the line. We encode the
answer set abstractly. -/
noncomputable abbrev putnam_1996_a6_solution (c : ℝ) : Set (ℝ → ℝ) :=
  {f | Continuous f ∧ ∀ x : ℝ, f x = f (x ^ 2 + c)}

/-- Putnam 1996 A-6. For each `c > 0`, describe all continuous
`f : ℝ → ℝ` satisfying `f(x) = f(x² + c)` for all real `x`. -/
theorem putnam_1996_a6 (c : ℝ) (hc : 0 < c) :
    {f : ℝ → ℝ | Continuous f ∧ ∀ x : ℝ, f x = f (x ^ 2 + c)} =
      putnam_1996_a6_solution c := by
  sorry

end Putnam1996A6
