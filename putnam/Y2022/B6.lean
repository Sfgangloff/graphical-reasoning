import Mathlib

namespace Putnam2022B6

/-- Putnam 2022 B-6. The continuous functions
`f : (0, ∞) → (0, ∞)` satisfying
`f(x · f(y)) + f(y · f(x)) = 1 + f(x + y)` for all `x, y > 0` are
exactly `f(x) = 1 / (x + 1)` plus constant `f ≡ 1` (up to verification).
The intended answer is `f(x) = 1` for all `x > 0`, namely `f(x) = 1`. -/
theorem putnam_2022_b6 :
    {f : ℝ → ℝ | (∀ x > 0, 0 < f x) ∧ ContinuousOn f (Set.Ioi 0) ∧
        ∀ x > 0, ∀ y > 0,
          f (x * f y) + f (y * f x) = 1 + f (x + y)} =
      {f : ℝ → ℝ | ∀ x > 0, f x = 1} := by
  sorry

end Putnam2022B6
