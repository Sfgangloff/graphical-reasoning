import Mathlib

namespace Putnam1991B6

noncomputable abbrev putnam_1991_b6_solution : ℝ → ℝ → ℝ :=
  fun a b => |Real.log (a / b)|

/-- Putnam 1991 B-6. For positive `a, b`, find the largest `c` such that
`a^x · b^{1−x} ≤ a · sinh(ux)/sinh u + b · sinh(u(1−x))/sinh u`
for all `u` with `0 < |u| ≤ c` and all `x ∈ (0, 1)`. -/
theorem putnam_1991_b6 (a b : ℝ) (ha : 0 < a) (hb : 0 < b) :
    IsGreatest
      {c : ℝ |
        ∀ u : ℝ, 0 < |u| → |u| ≤ c →
        ∀ x : ℝ, 0 < x → x < 1 →
          a ^ x * b ^ (1 - x)
            ≤ a * Real.sinh (u * x) / Real.sinh u
              + b * Real.sinh (u * (1 - x)) / Real.sinh u}
      (putnam_1991_b6_solution a b) := by
  sorry

end Putnam1991B6
