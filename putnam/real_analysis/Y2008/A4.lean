import Mathlib

namespace Putnam2008A4

/-- Putnam 2008 A-4. Define `f : ℝ → ℝ` recursively by `f x = x` for
`x ≤ e` and `f x = x · f (ln x)` for `x > e`. Then
`∑_{n=1}^∞ 1/f(n)` diverges. -/
theorem putnam_2008_a4
    (f : ℝ → ℝ)
    (hf_le : ∀ x ≤ Real.exp 1, f x = x)
    (hf_gt : ∀ x > Real.exp 1, f x = x * f (Real.log x)) :
    ¬ Summable (fun n : ℕ => 1 / f (n + 1)) := by
  sorry

end Putnam2008A4
