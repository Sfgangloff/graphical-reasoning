import Mathlib

namespace Putnam2025B2

/-- Putnam 2025 B-2. Let `f : [0, 1] → [0, ∞)` be strictly increasing
and continuous. Let `R` be the region bounded by `x = 0`, `x = 1`,
`y = 0`, `y = f x`. Let `x₁` be the `x`-coordinate of the centroid of
`R`, and `x₂` the `x`-coordinate of the centroid of the solid obtained
by rotating `R` about the `x`-axis. Then `x₁ < x₂`. -/
theorem putnam_2025_b2
    (f : ℝ → ℝ) (hcont : ContinuousOn f (Set.Icc 0 1))
    (hpos : ∀ x ∈ Set.Icc (0 : ℝ) 1, 0 ≤ f x)
    (hmono : StrictMonoOn f (Set.Icc 0 1)) :
    (∫ x in (0:ℝ)..1, x * f x) / (∫ x in (0:ℝ)..1, f x) <
      (∫ x in (0:ℝ)..1, x * (f x) ^ 2) / (∫ x in (0:ℝ)..1, (f x) ^ 2) := by
  sorry

end Putnam2025B2
