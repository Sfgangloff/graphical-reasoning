import Mathlib

namespace Putnam2014B2

/-- Putnam 2014 B-2. Suppose `f : [1, 3] → ℝ` is integrable,
`-1 ≤ f x ≤ 1` for all `x`, and `∫_1^3 f x = 0`. The supremum of
`∫_1^3 f(x)/x dx` over such `f` is `log(4/3)`. -/
theorem putnam_2014_b2 :
    sSup {y : ℝ | ∃ f : ℝ → ℝ,
        (∀ x ∈ Set.Icc (1 : ℝ) 3, -1 ≤ f x ∧ f x ≤ 1) ∧
        IntervalIntegrable f MeasureTheory.volume 1 3 ∧
        (∫ x in (1:ℝ)..3, f x) = 0 ∧
        y = ∫ x in (1:ℝ)..3, f x / x} =
      Real.log (4 / 3) := by
  sorry

end Putnam2014B2
