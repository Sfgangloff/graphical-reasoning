import Mathlib

namespace Putnam1999B3

open scoped BigOperators

/-- Putnam 1999 B-3. Let `A = {(x,y) : 0 ≤ x, y < 1}`. For `(x,y) ∈ A`
let
`S(x,y) = ∑_{1/2 ≤ m/n ≤ 2} x^m y^n`,
the sum running over all positive integer pairs `(m,n)` with `1/2 ≤ m/n ≤ 2`.
Then the limit
`lim_{(x,y) → (1,1), (x,y) ∈ A} (1 - x y²)(1 - x² y) S(x,y)`
exists. -/
theorem putnam_1999_b3
    (S : ℝ → ℝ → ℝ)
    (hS : ∀ x y : ℝ, S x y =
      ∑' p : {p : ℕ × ℕ // 0 < p.1 ∧ 0 < p.2 ∧
        (p.2 : ℝ) ≤ 2 * p.1 ∧ (p.1 : ℝ) ≤ 2 * p.2},
        x ^ p.val.1 * y ^ p.val.2) :
    ∃ L : ℝ,
      Filter.Tendsto (fun p : ℝ × ℝ =>
          (1 - p.1 * p.2 ^ 2) * (1 - p.1 ^ 2 * p.2) * S p.1 p.2)
        (nhdsWithin (1, 1) ({p | 0 ≤ p.1 ∧ p.1 < 1 ∧ 0 ≤ p.2 ∧ p.2 < 1}))
        (nhds L) := by
  sorry

end Putnam1999B3
