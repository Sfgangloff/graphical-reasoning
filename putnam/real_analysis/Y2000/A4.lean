import Mathlib

namespace Putnam2000A4

/-- Putnam 2000 A-4. The improper integral
`lim_{B→∞} ∫₀^B sin(x) sin(x²) dx`
converges. -/
theorem putnam_2000_a4 :
    ∃ L : ℝ,
      Filter.Tendsto
        (fun B : ℝ => ∫ x in (0 : ℝ)..B, Real.sin x * Real.sin (x ^ 2))
        Filter.atTop (nhds L) := by
  sorry

end Putnam2000A4
