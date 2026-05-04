import Mathlib

namespace Putnam2018A3

open scoped BigOperators

/-- Putnam 2018 A-3. The greatest possible value of
`∑_{i=1}^{10} cos(3 x_i)`
over real `x_1, …, x_{10}` with `∑_{i=1}^{10} cos(x_i) = 0` is `480/49`. -/
theorem putnam_2018_a3 :
    sSup {y : ℝ | ∃ x : Fin 10 → ℝ,
        (∑ i, Real.cos (x i)) = 0 ∧
        y = ∑ i, Real.cos (3 * x i)} = 480 / 49 := by
  sorry

end Putnam2018A3
