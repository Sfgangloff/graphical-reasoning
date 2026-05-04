import Mathlib

namespace Putnam2009B5

/-- Putnam 2009 B-5. If `f : (1, ∞) → ℝ` is differentiable with
`f'(x) = (x² − f(x)²) / (x² (f(x)² + 1))` for all `x > 1`, then
`f(x) → ∞` as `x → ∞`. -/
theorem putnam_2009_b5
    (f : ℝ → ℝ)
    (hf : DifferentiableOn ℝ f (Set.Ioi 1))
    (heq : ∀ x > 1, deriv f x = (x ^ 2 - (f x) ^ 2) / (x ^ 2 * ((f x) ^ 2 + 1))) :
    Filter.Tendsto f Filter.atTop Filter.atTop := by
  sorry

end Putnam2009B5
