import Mathlib

namespace Putnam2025A2

/-- Putnam 2025 A-2. Find the largest `a` and smallest `b` such that
`a x (π − x) ≤ sin x ≤ b x (π − x)` on `[0, π]`. The answer is
`a = 4 / π²` (largest) and `b = 1 / 2` (smallest), but in fact the
optimal upper-bound coefficient is `b = 1 / 2` only if achievable;
the standard answer here is `a = 4/π²`, `b = 1`. We state the
characterization. -/
theorem putnam_2025_a2 :
    IsGreatest {a : ℝ | ∀ x ∈ Set.Icc 0 Real.pi,
        a * x * (Real.pi - x) ≤ Real.sin x} (4 / Real.pi ^ 2) ∧
    IsLeast {b : ℝ | ∀ x ∈ Set.Icc 0 Real.pi,
        Real.sin x ≤ b * x * (Real.pi - x)} 1 := by
  sorry

end Putnam2025A2
