import Mathlib

namespace Putnam2000A1

/-- Putnam 2000 A-1. Let `A` be a positive real. The set of possible
values of `∑_{j=0}^∞ x_j²` for sequences of positive reals
`(x_j)_{j≥0}` summing to `A` is the open interval `(0, A²)`. -/
theorem putnam_2000_a1
    (A : ℝ) (hA : 0 < A) :
    {S : ℝ | ∃ x : ℕ → ℝ, (∀ j, 0 < x j) ∧ HasSum x A ∧
        HasSum (fun j => (x j) ^ 2) S} = Set.Ioo 0 (A ^ 2) := by
  sorry

end Putnam2000A1
