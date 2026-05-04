import Mathlib

namespace Putnam1999B1

/-- Putnam 1999 B-1. Right triangle `ABC` has the right angle at `C` and
`∠BAC = θ`. Choose `D` on `AB` with `|AC| = |AD| = 1`, and choose `E` on
`BC` with `∠CDE = θ`. Let `F` be the foot of the perpendicular from `E`
to `BC` extended to meet `AB`. Then with `|EF|` viewed as a function of
`θ`, the limit as `θ → 0⁺` exists. -/
theorem putnam_1999_b1
    (EF : ℝ → ℝ)
    (hEF : ∀ θ ∈ Set.Ioo 0 (Real.pi / 2),
      EF θ = (1 - Real.cos θ) * Real.cos θ /
        (Real.cos θ + Real.sin θ * Real.tan (2 * θ))) :
    ∃ L : ℝ, Filter.Tendsto EF (nhdsWithin 0 (Set.Ioi 0)) (nhds L) := by
  sorry

end Putnam1999B1
