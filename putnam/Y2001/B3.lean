import Mathlib

namespace Putnam2001B3

/-- Putnam 2001 B-3. For positive `n`, let `⟨n⟩` denote the closest
integer to `√n`. The series
`∑_{n=1}^∞ (2^{⟨n⟩} + 2^{-⟨n⟩}) / 2^n`
converges (to 3). -/
theorem putnam_2001_b3
    (cl : ℕ → ℕ)
    (hcl : ∀ n, |(cl n : ℝ) - Real.sqrt n| ≤ 1 / 2) :
    HasSum (fun n : ℕ =>
      (2 ^ (cl (n + 1) : ℤ) + 2 ^ (-(cl (n + 1) : ℤ))) /
        (2 ^ (n + 1) : ℝ)) (3 : ℝ) := by
  sorry

end Putnam2001B3
