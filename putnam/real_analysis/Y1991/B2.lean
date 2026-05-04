import Mathlib

namespace Putnam1991B2

/-- Putnam 1991 B-2. Suppose `f, g : ℝ → ℝ` are non-constant, differentiable,
satisfy the addition formulas `f(x+y) = f x f y − g x g y` and
`g(x+y) = f x g y + g x f y`, and `f'(0) = 0`. Then `f² + g² = 1`. -/
theorem putnam_1991_b2 (f g : ℝ → ℝ)
    (hf : Differentiable ℝ f)
    (hg : Differentiable ℝ g)
    (hfnonconst : ¬ ∃ c, ∀ x, f x = c)
    (hgnonconst : ¬ ∃ c, ∀ x, g x = c)
    (haddf : ∀ x y, f (x + y) = f x * f y - g x * g y)
    (haddg : ∀ x y, g (x + y) = f x * g y + g x * f y)
    (hf'0 : deriv f 0 = 0) :
    ∀ x, (f x) ^ 2 + (g x) ^ 2 = 1 := by
  sorry

end Putnam1991B2
