import Mathlib

namespace Putnam1999B4

/-- Putnam 1999 B-4. Let `f : ℝ → ℝ` have continuous third derivative,
with `f`, `f'`, `f''`, `f'''` all positive everywhere, and
`f'''(x) ≤ f(x)` for all `x`. Then `f'(x) < 2 f(x)` for all `x`. -/
theorem putnam_1999_b4
    (f : ℝ → ℝ)
    (hf : ContDiff ℝ 3 f)
    (hpos0 : ∀ x, 0 < f x)
    (hpos1 : ∀ x, 0 < deriv f x)
    (hpos2 : ∀ x, 0 < iteratedDeriv 2 f x)
    (hpos3 : ∀ x, 0 < iteratedDeriv 3 f x)
    (hineq : ∀ x, iteratedDeriv 3 f x ≤ f x) :
    ∀ x, deriv f x < 2 * f x := by
  sorry

end Putnam1999B4
