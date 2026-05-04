import Mathlib

namespace Putnam2011A2

open scoped BigOperators

/-- Putnam 2011 A-2. Let `(a_n)` and `(b_n)` be sequences of positive
reals with `a_1 = b_1 = 1` and `b_n = b_{n-1} a_n − 2` for `n ≥ 2`.
Suppose `(b_n)` is bounded. Then `S = ∑_{n=1}^∞ 1/(a_1 ⋯ a_n)` converges
and equals `3/2`. -/
theorem putnam_2011_a2
    (a b : ℕ → ℝ)
    (hpos_a : ∀ n, 0 < a n) (hpos_b : ∀ n, 0 < b n)
    (ha1 : a 0 = 1) (hb1 : b 0 = 1)
    (hb : ∀ n, b (n + 1) = b n * a (n + 1) - 2)
    (M : ℝ) (hbnd : ∀ n, b n ≤ M) :
    HasSum (fun n : ℕ => 1 / (∏ i ∈ Finset.range (n + 1), a i)) (3 / 2) := by
  sorry

end Putnam2011A2
