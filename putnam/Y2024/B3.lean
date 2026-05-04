import Mathlib

namespace Putnam2024B3

/-- Putnam 2024 B-3. Let `r_n` be the `n`-th smallest positive solution
of `tan x = x` (in radians). For all `n ≥ 1`,
`0 < r_{n+1} − r_n − π < 1 / ((n² + n) π)`. -/
theorem putnam_2024_b3
    (r : ℕ → ℝ)
    (hpos : ∀ n, 0 < r n)
    (hmono : StrictMono r)
    (hroot : ∀ n, Real.tan (r n) = r n)
    (hmin : ∀ x, 0 < x → Real.tan x = x → ∀ n, x ∈ Set.Icc (r n) (r (n + 1))) :
    ∀ n ≥ 1, 0 < r (n + 1) - r n - Real.pi ∧
      r (n + 1) - r n - Real.pi < 1 / (((n : ℝ) ^ 2 + n) * Real.pi) := by
  sorry

end Putnam2024B3
