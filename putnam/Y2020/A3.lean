import Mathlib

namespace Putnam2020A3

/-- Putnam 2020 A-3. Let `a_0 = π/2` and `a_n = sin(a_{n-1})` for
`n ≥ 1`. Then `∑_{n=1}^∞ a_n²` diverges. -/
theorem putnam_2020_a3
    (a : ℕ → ℝ)
    (ha0 : a 0 = Real.pi / 2)
    (ha : ∀ n, a (n + 1) = Real.sin (a n)) :
    ¬ Summable (fun n : ℕ => (a (n + 1)) ^ 2) := by
  sorry

end Putnam2020A3
