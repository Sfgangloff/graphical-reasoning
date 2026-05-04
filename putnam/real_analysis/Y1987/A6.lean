import Mathlib

namespace Putnam1987A6

/-- Number of zeros in the base-3 representation of `n`. -/
def numZerosBase3 (n : ℕ) : ℕ := (Nat.digits 3 n).count 0

abbrev putnam_1987_a6_solution : Set ℝ := Set.Ioo 0 25

/-- Putnam 1987 A-6. For which positive `x` does
`∑_{n=1}^∞ x^{a(n)} / n^3` converge, where `a(n)` is the number of zeros
in the base-3 representation of `n`? -/
theorem putnam_1987_a6 (x : ℝ) (hx : 0 < x) :
    Summable (fun n : ℕ+ => x ^ (numZerosBase3 n) / (n : ℝ) ^ 3)
      ↔ x ∈ putnam_1987_a6_solution := by
  sorry

end Putnam1987A6
