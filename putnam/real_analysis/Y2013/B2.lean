import Mathlib

namespace Putnam2013B2

open scoped BigOperators

/-- Putnam 2013 B-2. Let `C = ⋃_N C_N`, where `C_N` is the set of cosine
polynomials `f(x) = 1 + ∑_{n=1}^N a_n cos(2π n x)` such that
(i) `f(x) ≥ 0` for all real `x`, and
(ii) `a_n = 0` whenever `3 ∣ n`.
The maximum value of `f(0)` over `f ∈ C` is `3`. -/
theorem putnam_2013_b2 :
    sSup {y : ℝ | ∃ N : ℕ, ∃ a : ℕ → ℝ,
        (∀ n, 3 ∣ n → a n = 0) ∧
        (∀ x : ℝ, 0 ≤ 1 + ∑ n ∈ Finset.Icc 1 N, a n * Real.cos (2 * Real.pi * n * x)) ∧
        y = 1 + ∑ n ∈ Finset.Icc 1 N, a n} = 3 := by
  sorry

end Putnam2013B2
