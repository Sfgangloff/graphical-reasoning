import Mathlib

namespace Putnam2006B5

/-- Putnam 2006 B-5. For continuous `f : [0, 1] → ℝ`, let
`I(f) = ∫₀¹ x² f(x) dx` and `J(f) = ∫₀¹ x (f(x))² dx`. The maximum of
`I(f) − J(f)` is `1/16`. -/
theorem putnam_2006_b5 :
    sSup {y : ℝ | ∃ f : ℝ → ℝ, ContinuousOn f (Set.Icc 0 1) ∧
        y = (∫ x in (0:ℝ)..1, x ^ 2 * f x) -
              (∫ x in (0:ℝ)..1, x * (f x) ^ 2)} =
      1 / 16 := by
  sorry

end Putnam2006B5
