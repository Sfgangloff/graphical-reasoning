import Mathlib

open MeasureTheory intervalIntegral Set

/-- Putnam 1989 A2.

Evaluate `∫₀ᵃ ∫₀ᵇ e^{max{b²x², a²y²}} dy dx` for positive `a`, `b`.

Splitting the rectangle along the diagonal `b·x = a·y`, on each piece the
integrand is `e^{b²x²}` resp. `e^{a²y²}`; computing both contributions
(swapping the order of integration on the second so the elementary
substitution applies) each gives `(e^{a²b²} − 1)/(2ab)`, hence the
total is `(e^{a²b²} − 1)/(ab)`. -/
noncomputable def putnam_1989_a2_solution : ℝ → ℝ → ℝ :=
  fun a b => (Real.exp (a ^ 2 * b ^ 2) - 1) / (a * b)

theorem putnam_1989_a2
    (a b : ℝ)
    (abpos : a > 0 ∧ b > 0) :
    (∫ x in Set.Ioo 0 a, ∫ y in Set.Ioo 0 b,
        Real.exp (max (b ^ 2 * x ^ 2) (a ^ 2 * y ^ 2)))
      = putnam_1989_a2_solution a b := by
  sorry
