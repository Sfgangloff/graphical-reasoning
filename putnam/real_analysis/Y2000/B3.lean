import Mathlib

namespace Putnam2000B3

open scoped BigOperators

/-- Putnam 2000 B-3. Let `f(t) = ∑_{j=1}^N a_j sin(2π j t)` with each
`a_j ∈ ℝ` and `a_N ≠ 0`. For `k ≥ 0` let `N_k` denote the number of
zeros (with multiplicity) of `(d/dt)^k f` lying in `[0, 1)`. Then the
sequence `N_k` is nondecreasing and tends to `2N`. -/
theorem putnam_2000_b3
    (N : ℕ) (hN : 0 < N) (a : ℕ → ℝ) (haN : a N ≠ 0)
    (f : ℝ → ℝ)
    (hf : ∀ t, f t = ∑ j ∈ Finset.Icc 1 N, a j * Real.sin (2 * Real.pi * j * t))
    (Nk : ℕ → ℕ)
    (hNk : ∀ k,
      Nk k = ∑ᶠ t ∈ {t : ℝ | t ∈ Set.Ico (0 : ℝ) 1 ∧ iteratedDeriv k f t = 0},
        (1 : ℕ)) :
    (∀ k, Nk k ≤ Nk (k + 1)) ∧
      Filter.Tendsto Nk Filter.atTop (nhds (2 * N)) := by
  sorry

end Putnam2000B3
