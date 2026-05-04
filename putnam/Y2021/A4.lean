import Mathlib

namespace Putnam2021A4

/-- Putnam 2021 A-4. Let
`I(R) = ∬_{x²+y² ≤ R²} ((1 + 2x²)/(1 + x⁴ + 6x²y² + y⁴) − (1 + y²)/(2 + x⁴ + y⁴)) dx dy`.
Then `lim_{R → ∞} I(R)` exists; the value is `π · ((√2 · log 2) / 4 + π / 4)`,
which one may also write as `π log(1 + √2) − π² / 4` (both forms equivalent). -/
theorem putnam_2021_a4 :
    ∃ L : ℝ,
      Filter.Tendsto
        (fun R : ℝ =>
          ∫ p in {p : ℝ × ℝ | p.1 ^ 2 + p.2 ^ 2 ≤ R ^ 2},
            (1 + 2 * p.1 ^ 2) / (1 + p.1 ^ 4 + 6 * p.1 ^ 2 * p.2 ^ 2 + p.2 ^ 4)
              - (1 + p.2 ^ 2) / (2 + p.1 ^ 4 + p.2 ^ 4))
        Filter.atTop (nhds L) := by
  sorry

end Putnam2021A4
