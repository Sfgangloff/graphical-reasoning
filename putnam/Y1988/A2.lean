import Mathlib

namespace Putnam1988A2

abbrev putnam_1988_a2_solution : Prop := True

/-- Putnam 1988 A-2. With `f(x) = e^{x²}`, does there exist an open interval
`(a, b)` and a nonzero differentiable function `g` on `(a, b)` such that
the wrong product rule `(f g)' = f' g'` holds throughout? -/
theorem putnam_1988_a2 :
    (∃ a b : ℝ, a < b ∧ ∃ g : ℝ → ℝ,
        (∃ x ∈ Set.Ioo a b, g x ≠ 0) ∧
        DifferentiableOn ℝ g (Set.Ioo a b) ∧
        ∀ x ∈ Set.Ioo a b,
          deriv (fun y => Real.exp (y ^ 2) * g y) x =
            deriv (fun y => Real.exp (y ^ 2)) x * deriv g x)
      ↔ putnam_1988_a2_solution := by
  sorry

end Putnam1988A2
