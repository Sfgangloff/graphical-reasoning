import Mathlib

namespace Putnam2001B5

/-- Putnam 2001 B-5. Let `a, b ∈ (0, 1/2)` and let `g : ℝ → ℝ` be
continuous with `g(g(x)) = a g(x) + b x` for all real `x`. Then `g`
must be linear: there exists `c` with `g(x) = c x`. -/
theorem putnam_2001_b5
    (a b : ℝ) (ha : a ∈ Set.Ioo (0 : ℝ) (1 / 2))
    (hb : b ∈ Set.Ioo (0 : ℝ) (1 / 2))
    (g : ℝ → ℝ) (hg : Continuous g)
    (heq : ∀ x : ℝ, g (g x) = a * g x + b * x) :
    ∃ c : ℝ, ∀ x : ℝ, g x = c * x := by
  sorry

end Putnam2001B5
