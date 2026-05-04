import Mathlib

namespace Putnam2016A3

/-- Putnam 2016 A-3. Suppose `f : ℝ → ℝ` satisfies
`f(x) + f(1 − 1/x) = arctan x` for all `x ≠ 0`. Then
`∫₀¹ f(x) dx = (3 π · log 2) / 8`. -/
theorem putnam_2016_a3
    (f : ℝ → ℝ)
    (heq : ∀ x : ℝ, x ≠ 0 → f x + f (1 - 1 / x) = Real.arctan x) :
    (∫ x in (0:ℝ)..1, f x) = (3 * Real.pi * Real.log 2) / 8 := by
  sorry

end Putnam2016A3
