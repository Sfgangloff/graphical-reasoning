import Mathlib

namespace Putnam2024B6

/-- Putnam 2024 B-6. For real `a`, let
`F_a(x) = ∑_{n ≥ 1} n^a · e^{2 n} · x^{n²}` for `0 ≤ x < 1`. The unique
real `c` such that
`lim_{x → 1⁻} F_a(x) · e^{-1/(1-x)} = 0` for `a < c` and `= ∞` for
`a > c` is `c = -1/2`. -/
theorem putnam_2024_b6 :
    ∃! c : ℝ,
      (∀ a : ℝ, a < c →
        Filter.Tendsto
          (fun x : ℝ => (∑' n : ℕ, (n + 1 : ℝ) ^ a * Real.exp (2 * (n + 1)) *
            x ^ ((n + 1) ^ 2)) * Real.exp (-(1 / (1 - x))))
          (nhdsWithin 1 (Set.Iio 1)) (nhds 0)) ∧
      (∀ a : ℝ, a > c →
        Filter.Tendsto
          (fun x : ℝ => (∑' n : ℕ, (n + 1 : ℝ) ^ a * Real.exp (2 * (n + 1)) *
            x ^ ((n + 1) ^ 2)) * Real.exp (-(1 / (1 - x))))
          (nhdsWithin 1 (Set.Iio 1)) Filter.atTop) := by
  sorry

end Putnam2024B6
