import Mathlib

namespace Putnam2023A3

/-- Putnam 2023 A-3. The smallest positive `r` such that there exist
differentiable `f, g : ℝ → ℝ` with `f(0) > 0`, `g(0) = 0`,
`|f'(x)| ≤ |g(x)|`, `|g'(x)| ≤ |f(x)|`, and `f(r) = 0` is `r = π / 2`. -/
theorem putnam_2023_a3 :
    IsLeast {r : ℝ | 0 < r ∧ ∃ f g : ℝ → ℝ,
        Differentiable ℝ f ∧ Differentiable ℝ g ∧
        f 0 > 0 ∧ g 0 = 0 ∧
        (∀ x, |deriv f x| ≤ |g x|) ∧
        (∀ x, |deriv g x| ≤ |f x|) ∧
        f r = 0} (Real.pi / 2) := by
  sorry

end Putnam2023A3
