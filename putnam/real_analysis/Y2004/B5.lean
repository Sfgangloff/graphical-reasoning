import Mathlib

namespace Putnam2004B5

/-- Putnam 2004 B-5. Evaluate
`lim_{x → 1⁻} ∏_{n=0}^∞ ((1 + x^{n+1}) / (1 + x^n))^{x^n}`. The limit
is `2/e`. -/
theorem putnam_2004_b5 :
    Filter.Tendsto
      (fun x : ℝ =>
        ∏' n : ℕ, ((1 + x ^ (n + 1)) / (1 + x ^ n)) ^ (x ^ n))
      (nhdsWithin 1 (Set.Iio 1))
      (nhds (2 / Real.exp 1)) := by
  sorry

end Putnam2004B5
