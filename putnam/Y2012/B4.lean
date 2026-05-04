import Mathlib

namespace Putnam2012B4

/-- Putnam 2012 B-4. Let `a_0 = 1` and `a_{n+1} = a_n + e^{−a_n}`. Then
`a_n − log n` has a finite limit as `n → ∞`. -/
theorem putnam_2012_b4
    (a : ℕ → ℝ)
    (ha0 : a 0 = 1)
    (ha : ∀ n, a (n + 1) = a n + Real.exp (-(a n))) :
    ∃ L : ℝ,
      Filter.Tendsto (fun n : ℕ => a n - Real.log n) Filter.atTop (nhds L) := by
  sorry

end Putnam2012B4
