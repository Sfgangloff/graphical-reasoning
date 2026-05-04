import Mathlib

namespace Putnam2015B1

/-- Putnam 2015 B-1. If `f : ℝ → ℝ` is three times differentiable and
has at least five distinct real zeros, then `f + 6 f' + 12 f'' + 8 f'''`
has at least two distinct real zeros. -/
theorem putnam_2015_b1
    (f : ℝ → ℝ) (hf : ContDiff ℝ 3 f)
    (Z : Set ℝ) (hZ : Z ⊆ {x | f x = 0}) (hZ5 : 5 ≤ Z.ncard) :
    {x : ℝ |
        f x + 6 * deriv f x + 12 * iteratedDeriv 2 f x +
            8 * iteratedDeriv 3 f x = 0}.ncard ≥ 2 := by
  sorry

end Putnam2015B1
