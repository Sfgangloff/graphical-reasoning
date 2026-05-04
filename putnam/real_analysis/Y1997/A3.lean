import Mathlib

namespace Putnam1997A3

/-- Solution: `√e`. -/
noncomputable abbrev putnam_1997_a3_solution : ℝ := Real.sqrt (Real.exp 1)

/-- Putnam 1997 A-3. Evaluate
`∫_0^∞ (∑_{k≥0} (-1)^k x^{2k+1} / (2k)!!) · (∑_{k≥0} x^{2k} / ((2k)!!)^2) dx`.
Equivalently, `∫_0^∞ x · e^{-x²/2} · I₀(x) dx`. -/
theorem putnam_1997_a3 :
    (∫ x in Set.Ioi (0 : ℝ),
        (∑' k : ℕ, (-1 : ℝ) ^ k * x ^ (2 * k + 1) /
          ∏ i ∈ Finset.range k, (2 * (i + 1) : ℝ)) *
        (∑' k : ℕ, x ^ (2 * k) /
          (∏ i ∈ Finset.range k, (2 * (i + 1) : ℝ)) ^ 2)) =
    putnam_1997_a3_solution := by
  sorry

end Putnam1997A3
