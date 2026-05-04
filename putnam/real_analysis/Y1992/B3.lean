import Mathlib

open Filter Topology

namespace Putnam1992B3

/-- Iteration `a₀(x,y) = x`, `a_{n+1}(x,y) = (aₙ² + y²) / 2`. -/
noncomputable def a (x y : ℝ) : ℕ → ℝ
  | 0 => x
  | n + 1 => ((a x y n) ^ 2 + y ^ 2) / 2

noncomputable abbrev putnam_1992_b3_solution : ℝ := 2 + Real.pi / 2

/-- Putnam 1992 B-3. Find the area of the set of `(x, y)` for which
`(aₙ(x, y))_{n ≥ 0}` converges. -/
theorem putnam_1992_b3 :
    MeasureTheory.volume
        {p : ℝ × ℝ | ∃ L, Tendsto (fun n => a p.1 p.2 n) atTop (𝓝 L)}
      = ENNReal.ofReal putnam_1992_b3_solution := by
  sorry

end Putnam1992B3
