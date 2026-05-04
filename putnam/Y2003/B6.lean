import Mathlib

namespace Putnam2003B6

/-- Putnam 2003 B-6. For continuous `f : [0,1] → ℝ`,
`∫₀¹ ∫₀¹ |f(x) + f(y)| dx dy ≥ ∫₀¹ |f(x)| dx`. -/
theorem putnam_2003_b6
    (f : ℝ → ℝ) (hf : ContinuousOn f (Set.Icc 0 1)) :
    (∫ x in (0:ℝ)..1, ∫ y in (0:ℝ)..1, |f x + f y|) ≥
      ∫ x in (0:ℝ)..1, |f x| := by
  sorry

end Putnam2003B6
