import Mathlib

namespace Putnam1994A1

/-- Putnam 1994 A-1. If a sequence `(a_n)` of reals satisfies
`0 < a_n ≤ a_{2n} + a_{2n+1}` for all `n ≥ 1`, then the series `∑_{n≥1} a_n`
diverges. -/
theorem putnam_1994_a1
    (a : ℕ → ℝ)
    (ha : ∀ n ≥ 1, 0 < a n ∧ a n ≤ a (2 * n) + a (2 * n + 1)) :
    ¬ Summable (fun n : ℕ => a (n + 1)) := by
  sorry

end Putnam1994A1
