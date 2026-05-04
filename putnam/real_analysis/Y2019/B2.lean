import Mathlib

namespace Putnam2019B2

open scoped BigOperators

/-- Putnam 2019 B-2. For `n ≥ 1` let
`a_n = ∑_{k=1}^{n-1} sin((2k-1)π/(2n)) / (cos²((k-1)π/(2n)) cos²(kπ/(2n)))`.
Then `a_n / n³ → 8/π³`. -/
theorem putnam_2019_b2
    (a : ℕ → ℝ)
    (ha : ∀ n, 1 ≤ n →
      a n = ∑ k ∈ Finset.Icc 1 (n - 1),
        Real.sin ((2 * k - 1) * Real.pi / (2 * n)) /
          (Real.cos ((k - 1) * Real.pi / (2 * n)) ^ 2 *
            Real.cos (k * Real.pi / (2 * n)) ^ 2)) :
    Filter.Tendsto (fun n : ℕ => a n / n ^ 3) Filter.atTop
      (nhds (8 / Real.pi ^ 3)) := by
  sorry

end Putnam2019B2
