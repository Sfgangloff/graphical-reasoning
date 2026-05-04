import Mathlib

namespace Putnam2018A5

/-- Putnam 2018 A-5. Suppose `f : ℝ → ℝ` is smooth with `f(0) = 0`,
`f(1) = 1`, and `f x ≥ 0` for all `x`. Then there is a positive integer
`n` and a real `x` with `f^{(n)}(x) < 0`. -/
theorem putnam_2018_a5
    (f : ℝ → ℝ) (hf : ContDiff ℝ ⊤ f)
    (hf0 : f 0 = 0) (hf1 : f 1 = 1) (hpos : ∀ x, 0 ≤ f x) :
    ∃ n : ℕ, 0 < n ∧ ∃ x : ℝ, iteratedDeriv n f x < 0 := by
  sorry

end Putnam2018A5
