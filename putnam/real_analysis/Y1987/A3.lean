import Mathlib

namespace Putnam1987A3

abbrev putnam_1987_a3_solution : Prop × Prop := (False, True)

/-- Putnam 1987 A-3.
A real-valued function `y = f(x)` satisfies `y'' - 2 y' + y = 2 eˣ`.
(a) If `f(x) > 0` for all `x`, must `f'(x) > 0` for all `x`?
(b) If `f'(x) > 0` for all `x`, must `f(x) > 0` for all `x`? -/
theorem putnam_1987_a3 :
    ((∀ f : ℝ → ℝ, ContDiff ℝ 2 f →
        (∀ x, deriv (deriv f) x - 2 * deriv f x + f x = 2 * Real.exp x) →
        (∀ x, 0 < f x) → (∀ x, 0 < deriv f x))
      ↔ putnam_1987_a3_solution.1)
    ∧
    ((∀ f : ℝ → ℝ, ContDiff ℝ 2 f →
        (∀ x, deriv (deriv f) x - 2 * deriv f x + f x = 2 * Real.exp x) →
        (∀ x, 0 < deriv f x) → (∀ x, 0 < f x))
      ↔ putnam_1987_a3_solution.2) := by
  sorry

end Putnam1987A3
