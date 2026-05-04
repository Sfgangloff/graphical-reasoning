import Mathlib

namespace Putnam2002A6

/-- Putnam 2002 A-6. Fix `b ≥ 2`, set `f(1) = 1`, `f(2) = 2` and for
`n ≥ 3` let `f(n) = n · f(d)` where `d` is the number of base-`b`
digits of `n`. The series `∑_{n≥1} 1/f(n)` converges if and only if
`b = 2`. -/
theorem putnam_2002_a6
    (b : ℕ) (hb : 2 ≤ b) (f : ℕ → ℝ)
    (hf1 : f 1 = 1) (hf2 : f 2 = 2)
    (hf : ∀ n, 3 ≤ n → f n = n * f (Nat.log b n + 1)) :
    Summable (fun n : ℕ => 1 / f (n + 1)) ↔ b = 2 := by
  sorry

end Putnam2002A6
