import Mathlib

namespace Putnam2020A6

open scoped BigOperators

/-- Putnam 2020 A-6. For positive `N`, let
`f_N(x) = ∑_{n=0}^N ((N + 1/2 − n) / ((N+1)(2n+1))) · sin((2n+1) x)`.
The smallest `M` such that `f_N(x) ≤ M` for all `N ≥ 1` and all real `x`
is `M = π / 4`. -/
theorem putnam_2020_a6
    (f : ℕ → ℝ → ℝ)
    (hf : ∀ N x, f N x =
      ∑ n ∈ Finset.range (N + 1),
        ((N + 1 / 2 - n) / ((N + 1) * (2 * n + 1))) * Real.sin ((2 * n + 1) * x)) :
    IsLeast {M : ℝ | ∀ N : ℕ, 1 ≤ N → ∀ x : ℝ, f N x ≤ M} (Real.pi / 4) := by
  sorry

end Putnam2020A6
