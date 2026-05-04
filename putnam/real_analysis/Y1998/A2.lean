import Mathlib

namespace Putnam1998A2

/-- Putnam 1998 A-2. Let `s` be the arc of the unit circle from
`(cos θ₂, sin θ₂)` to `(cos θ₁, sin θ₁)` with `0 ≤ θ₁ < θ₂ ≤ π/2`.
Let `A = ∫_{cos θ₂}^{cos θ₁} √(1−x²) dx` (area below the arc, above the
`x`-axis) and `B = ∫_{sin θ₁}^{sin θ₂} √(1−y²) dy` (area right of the
`y`-axis, left of the arc). Then `A + B` depends only on the arc
length `θ₂ − θ₁`. -/
theorem putnam_1998_a2 :
    ∃ F : ℝ → ℝ, ∀ θ₁ θ₂ : ℝ,
      0 ≤ θ₁ → θ₁ < θ₂ → θ₂ ≤ Real.pi / 2 →
      (∫ x in Real.cos θ₂..Real.cos θ₁, Real.sqrt (1 - x ^ 2)) +
      (∫ y in Real.sin θ₁..Real.sin θ₂, Real.sqrt (1 - y ^ 2)) =
        F (θ₂ - θ₁) := by
  sorry

end Putnam1998A2
