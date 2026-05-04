import Mathlib

namespace Putnam2005B3

/-- Putnam 2005 B-3. Find all differentiable `f : (0, ∞) → (0, ∞)`
such that there exists `a > 0` with `f'(a/x) = x / f(x)` for all
`x > 0`. The solutions are `f(x) = c x^d` for any `c > 0` and `d > 0`
with `a = c^{2/(d+1)}`. -/
theorem putnam_2005_b3 :
    {f : ℝ → ℝ | (∀ x > 0, 0 < f x) ∧ DifferentiableOn ℝ f (Set.Ioi 0) ∧
        ∃ a > 0, ∀ x > 0, deriv f (a / x) = x / f x} =
      {f : ℝ → ℝ | ∃ c > 0, ∃ d > 0, ∀ x > 0, f x = c * x ^ d} := by
  sorry

end Putnam2005B3
