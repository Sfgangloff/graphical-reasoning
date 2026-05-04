import Mathlib

namespace Putnam2016B6

/-- Putnam 2016 B-6. Evaluate
`∑_{k=1}^∞ ((-1)^{k-1} / k) · ∑_{n=0}^∞ 1/(k 2^n + 1) = 1`. -/
theorem putnam_2016_b6 :
    HasSum (fun k : ℕ =>
        ((-1) ^ k / (k + 1 : ℝ)) *
          ∑' n : ℕ, 1 / ((k + 1) * 2 ^ n + 1 : ℝ))
      (1 : ℝ) := by
  sorry

end Putnam2016B6
