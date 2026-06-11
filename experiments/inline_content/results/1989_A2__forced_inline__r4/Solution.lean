import Mathlib

open scoped Real
open MeasureTheory

/-- The value of the double integral
`∫_0^a ∫_0^b e^{max(b²x², a²y²)} dy dx` for positive `a`, `b`. -/
noncomputable def putnam_1989_a2_solution : ℝ → ℝ → ℝ :=
  fun a b => (Real.exp (a ^ 2 * b ^ 2) - 1) / (a * b)

theorem putnam_1989_a2
    (a b : ℝ) (hab : 0 < a ∧ 0 < b) :
    (∫ x in Set.Ioo 0 a, ∫ y in Set.Ioo 0 b,
        Real.exp (max (b ^ 2 * x ^ 2) (a ^ 2 * y ^ 2)))
      = putnam_1989_a2_solution a b := by
  sorry
