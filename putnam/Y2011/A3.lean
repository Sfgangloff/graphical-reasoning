import Mathlib

namespace Putnam2011A3

/-- Putnam 2011 A-3. There exist `c ∈ ℝ` and `L > 0` with
`lim_{r → ∞} r^c · (∫₀^{π/2} x^r sin x dx) / (∫₀^{π/2} x^r cos x dx) = L`.
The values are `c = -1` and `L = 2 / π`. -/
theorem putnam_2011_a3 :
    Filter.Tendsto
      (fun r : ℝ =>
        r ^ (-(1 : ℝ)) *
          ((∫ x in (0:ℝ)..(Real.pi / 2), x ^ r * Real.sin x) /
            (∫ x in (0:ℝ)..(Real.pi / 2), x ^ r * Real.cos x)))
      Filter.atTop (nhds (2 / Real.pi)) := by
  sorry

end Putnam2011A3
