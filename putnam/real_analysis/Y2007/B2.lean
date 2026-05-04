import Mathlib

namespace Putnam2007B2

/-- Putnam 2007 B-2. Suppose `f : [0,1] → ℝ` has continuous derivative
and `∫₀¹ f = 0`. Then for every `α ∈ (0, 1)`,
`|∫₀^α f(x) dx| ≤ (1/8) · max_{x ∈ [0,1]} |f'(x)|`. -/
theorem putnam_2007_b2
    (f : ℝ → ℝ)
    (hf : ContDiffOn ℝ 1 f (Set.Icc 0 1))
    (hint : (∫ x in (0:ℝ)..1, f x) = 0)
    (M : ℝ)
    (hM : ∀ x ∈ Set.Icc (0:ℝ) 1, |deriv f x| ≤ M) :
    ∀ α ∈ Set.Ioo (0:ℝ) 1, |∫ x in (0:ℝ)..α, f x| ≤ M / 8 := by
  sorry

end Putnam2007B2
