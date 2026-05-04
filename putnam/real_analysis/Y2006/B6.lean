import Mathlib

namespace Putnam2006B6

/-- Putnam 2006 B-6. Let `k > 1` be an integer and `a₀ > 0`. Define
`a_{n+1} = a_n + 1 / a_n^{1/k}`. Then `a_n^{k+1} / n^k` tends to
`((k+1)/k)^k`. -/
theorem putnam_2006_b6
    (k : ℕ) (hk : 1 < k)
    (a : ℕ → ℝ)
    (ha0 : 0 < a 0)
    (ha : ∀ n, a (n + 1) = a n + 1 / (a n) ^ ((1 : ℝ) / k)) :
    Filter.Tendsto (fun n : ℕ => (a n) ^ (k + 1) / (n : ℝ) ^ k)
      Filter.atTop (nhds (((k + 1 : ℝ) / k) ^ k)) := by
  sorry

end Putnam2006B6
