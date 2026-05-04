import Mathlib

namespace Putnam2010A2

/-- Putnam 2010 A-2. Find all differentiable `f : ℝ → ℝ` such that for
all `x ∈ ℝ` and all positive integers `n`,
`f'(x) = (f(x + n) − f(x)) / n`. The solutions are exactly the affine
functions `f(x) = a x + b`. -/
theorem putnam_2010_a2 :
    {f : ℝ → ℝ | Differentiable ℝ f ∧
        ∀ x : ℝ, ∀ n : ℕ, 0 < n → deriv f x = (f (x + n) - f x) / n} =
      {f : ℝ → ℝ | ∃ a b : ℝ, ∀ x, f x = a * x + b} := by
  sorry

end Putnam2010A2
