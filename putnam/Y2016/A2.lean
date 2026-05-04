import Mathlib

namespace Putnam2016A2

/-- Putnam 2016 A-2. For positive `n`, let `M(n)` be the largest `m`
such that `C(m, n − 1) > C(m − 1, n)`. Then `M(n) / n → (3 + √5) / 2`. -/
theorem putnam_2016_a2
    (M : ℕ → ℕ)
    (hM : ∀ n, 0 < n → IsGreatest
      {m : ℕ | (m.choose (n - 1) : ℝ) > ((m - 1).choose n : ℝ)} (M n)) :
    Filter.Tendsto (fun n : ℕ => (M n : ℝ) / n) Filter.atTop
      (nhds ((3 + Real.sqrt 5) / 2)) := by
  sorry

end Putnam2016A2
