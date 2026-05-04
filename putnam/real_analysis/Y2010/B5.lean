import Mathlib

namespace Putnam2010B5

/-- Putnam 2010 B-5. There is no strictly increasing function
`f : ℝ → ℝ` with `f'(x) = f(f(x))` for all `x`. -/
theorem putnam_2010_b5 :
    ¬ ∃ f : ℝ → ℝ, StrictMono f ∧ Differentiable ℝ f ∧
      ∀ x, deriv f x = f (f x) := by
  sorry

end Putnam2010B5
