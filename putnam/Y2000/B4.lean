import Mathlib

namespace Putnam2000B4

/-- Putnam 2000 B-4. If `f : ℝ → ℝ` is continuous and satisfies
`f(2x² − 1) = 2x · f(x)` for all `x`, then `f(x) = 0` on `[-1, 1]`. -/
theorem putnam_2000_b4
    (f : ℝ → ℝ) (hf : Continuous f)
    (heq : ∀ x : ℝ, f (2 * x ^ 2 - 1) = 2 * x * f x) :
    ∀ x ∈ Set.Icc (-1 : ℝ) 1, f x = 0 := by
  sorry

end Putnam2000B4
