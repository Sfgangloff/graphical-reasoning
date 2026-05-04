import Mathlib

namespace Putnam2004A6

/-- Putnam 2004 A-6. For `f : [0,1]² → ℝ` continuous,
`∫₀¹ (∫₀¹ f(x,y) dx)² dy + ∫₀¹ (∫₀¹ f(x,y) dy)² dx`
is at most `(∫∫ f)² + ∫∫ f²`. -/
theorem putnam_2004_a6
    (f : ℝ → ℝ → ℝ)
    (hf : ContinuousOn (fun p : ℝ × ℝ => f p.1 p.2)
            (Set.Icc 0 1 ×ˢ Set.Icc 0 1)) :
    (∫ y in (0:ℝ)..1, (∫ x in (0:ℝ)..1, f x y) ^ 2) +
        (∫ x in (0:ℝ)..1, (∫ y in (0:ℝ)..1, f x y) ^ 2)
      ≤ (∫ x in (0:ℝ)..1, ∫ y in (0:ℝ)..1, f x y) ^ 2 +
          ∫ x in (0:ℝ)..1, ∫ y in (0:ℝ)..1, (f x y) ^ 2 := by
  sorry

end Putnam2004A6
