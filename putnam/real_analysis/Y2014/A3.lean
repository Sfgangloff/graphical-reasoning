import Mathlib

namespace Putnam2014A3

/-- Putnam 2014 A-3. Let `a_0 = 5/2` and `a_k = a_{k-1}² − 2`. Then
`∏_{k=0}^∞ (1 − 1/a_k) = 3/7`. -/
theorem putnam_2014_a3
    (a : ℕ → ℝ)
    (ha0 : a 0 = 5 / 2)
    (ha : ∀ k, a (k + 1) = (a k) ^ 2 - 2) :
    Filter.Tendsto
      (fun N : ℕ => ∏ k ∈ Finset.range N, (1 - 1 / a k))
      Filter.atTop (nhds (3 / 7)) := by
  sorry

end Putnam2014A3
