import Mathlib

namespace Putnam2012A6

/-- Putnam 2012 A-6. Suppose `f : ℝ² → ℝ` is continuous and the double
integral of `f` over every axis-aligned rectangle of area `1` is `0`.
Then `f ≡ 0`. -/
theorem putnam_2012_a6
    (f : ℝ × ℝ → ℝ) (hf : Continuous f)
    (hint : ∀ a b c d : ℝ, a < b → c < d → (b - a) * (d - c) = 1 →
      (∫ x in a..b, ∫ y in c..d, f (x, y)) = 0) :
    ∀ p, f p = 0 := by
  sorry

end Putnam2012A6
