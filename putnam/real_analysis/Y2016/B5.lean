import Mathlib

namespace Putnam2016B5

/-- Putnam 2016 B-5. The functions `f : (1, ∞) → (1, ∞)` such that
whenever `x² ≤ y ≤ x³` we have `(f x)² ≤ f y ≤ (f x)³` are exactly the
maps `f(x) = x^c` for some `c > 0`. -/
theorem putnam_2016_b5 :
    {f : ℝ → ℝ | (∀ x > 1, 1 < f x) ∧
        (∀ x y : ℝ, 1 < x → x ^ 2 ≤ y → y ≤ x ^ 3 →
          (f x) ^ 2 ≤ f y ∧ f y ≤ (f x) ^ 3)} =
      {f : ℝ → ℝ | ∃ c > 0, ∀ x > 1, f x = x ^ c} := by
  sorry

end Putnam2016B5
