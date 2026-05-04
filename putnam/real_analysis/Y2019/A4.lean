import Mathlib

namespace Putnam2019A4

/-- Putnam 2019 A-4. Suppose `f : ℝ³ → ℝ` is continuous and the
surface integral of `f` over every sphere of radius `1` in `ℝ³`
equals `0`. Must `f ≡ 0`? No. (Disprove.) -/
theorem putnam_2019_a4 :
    ¬ ∀ f : ℝ × ℝ × ℝ → ℝ, Continuous f →
      (∀ c : ℝ × ℝ × ℝ,
        (∫ p in Metric.sphere c 1, f p) = 0) →
      ∀ p, f p = 0 := by
  sorry

end Putnam2019A4
