import Mathlib

namespace Putnam2004B3

/-- Putnam 2004 B-3. The set of `a > 0` such that there exists a
continuous nonnegative `f : [0, a] → ℝ` whose region
`R = {(x, y) : 0 ≤ x ≤ a, 0 ≤ y ≤ f x}` has both perimeter and area
equal to a common value `k` is `{a : ℝ | 2 < a}`. -/
theorem putnam_2004_b3 :
    {a : ℝ | 0 < a ∧ ∃ f : ℝ → ℝ, ContinuousOn f (Set.Icc 0 a) ∧
        (∀ x ∈ Set.Icc (0 : ℝ) a, 0 ≤ f x) ∧
        ∃ k : ℝ,
          a + f 0 + f a +
              (∫ x in (0:ℝ)..a, Real.sqrt (1 + (deriv f x) ^ 2)) = k ∧
            (∫ x in (0:ℝ)..a, f x) = k} =
      {a : ℝ | 2 < a} := by
  sorry

end Putnam2004B3
