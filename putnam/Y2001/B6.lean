import Mathlib

namespace Putnam2001B6

/-- Putnam 2001 B-6. Let `(a_n)_{n≥1}` be a strictly increasing
sequence of positive reals with `a_n / n → 0`. Then there are
infinitely many `n` such that `a_{n-i} + a_{n+i} < 2 a_n` for all
`i = 1, …, n−1`. -/
theorem putnam_2001_b6
    (a : ℕ → ℝ)
    (hpos : ∀ n, 0 < a n)
    (hmono : StrictMono a)
    (hlim : Filter.Tendsto (fun n : ℕ => a n / n) Filter.atTop (nhds 0)) :
    {n : ℕ | 1 ≤ n ∧ ∀ i ∈ Finset.Ico 1 n, a (n - i) + a (n + i) < 2 * a n}.Infinite := by
  sorry

end Putnam2001B6
