import Mathlib

namespace Putnam2010A3

/-- Putnam 2010 A-3. Suppose `h : ℝ² → ℝ` has continuous partials and
satisfies `h(x,y) = a · ∂h/∂x + b · ∂h/∂y` for constants `a, b`. If
`|h| ≤ M` everywhere, then `h ≡ 0`. -/
theorem putnam_2010_a3
    (a b : ℝ) (h : ℝ × ℝ → ℝ)
    (hh : ContDiff ℝ 1 h)
    (heq : ∀ p : ℝ × ℝ,
      h p = a * (fderiv ℝ h p) (1, 0) + b * (fderiv ℝ h p) (0, 1))
    (M : ℝ) (hM : ∀ p, |h p| ≤ M) :
    ∀ p, h p = 0 := by
  sorry

end Putnam2010A3
