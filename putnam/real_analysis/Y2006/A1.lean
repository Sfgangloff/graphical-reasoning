import Mathlib

namespace Putnam2006A1

/-- Putnam 2006 A-1. The volume of the region of `(x, y, z) ∈ ℝ³` with
`(x² + y² + z² + 8)² ≤ 36 (x² + y²)` equals `6 π²`. -/
theorem putnam_2006_a1 :
    MeasureTheory.volume {p : ℝ × ℝ × ℝ |
      (p.1 ^ 2 + p.2.1 ^ 2 + p.2.2 ^ 2 + 8) ^ 2 ≤
        36 * (p.1 ^ 2 + p.2.1 ^ 2)} =
      ENNReal.ofReal (6 * Real.pi ^ 2) := by
  sorry

end Putnam2006A1
