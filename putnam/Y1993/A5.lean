import Mathlib

namespace Putnam1993A5

/-- The integrand `((x^2 - x) / (x^3 - 3x + 1))^2`. -/
noncomputable def f (x : ℝ) : ℝ := ((x ^ 2 - x) / (x ^ 3 - 3 * x + 1)) ^ 2

/-- Putnam 1993 A-5. Show that
`∫_{-100}^{-10} f + ∫_{1/101}^{1/11} f + ∫_{101/100}^{11/10} f`
is rational. -/
theorem putnam_1993_a5 :
    ∃ q : ℚ,
      (∫ x in (-100 : ℝ)..(-10), f x) +
      (∫ x in (1 / 101 : ℝ)..(1 / 11), f x) +
      (∫ x in (101 / 100 : ℝ)..(11 / 10), f x) = (q : ℝ) := by
  sorry

end Putnam1993A5
