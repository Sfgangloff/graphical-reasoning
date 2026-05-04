import Mathlib

namespace Putnam1997B2

/-- Putnam 1997 B-2. Let `f` be twice differentiable on `ℝ` and let
`g : ℝ → ℝ` be nonnegative, with `f(x) + f''(x) = -x · g(x) · f'(x)` for
all `x`. Then `|f|` is bounded on `ℝ`. -/
theorem putnam_1997_b2
    (f g : ℝ → ℝ)
    (hf : ContDiff ℝ 2 f)
    (hg : ∀ x, 0 ≤ g x)
    (heq : ∀ x, f x + iteratedDeriv 2 f x = - x * g x * deriv f x) :
    ∃ M : ℝ, ∀ x, |f x| ≤ M := by
  sorry

end Putnam1997B2
