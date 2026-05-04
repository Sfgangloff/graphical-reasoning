import Mathlib

namespace Putnam2002A1

/-- Putnam 2002 A-1. For a fixed positive integer `k`, the `n`-th
derivative of `1/(x^k − 1)` has the form `P_n(x) / (x^k − 1)^(n+1)` for
some polynomial `P_n`. The value at `x = 1` is `P_n(1) = (-k)^n · n!`. -/
theorem putnam_2002_a1
    (k : ℕ) (hk : 0 < k)
    (P : ℕ → Polynomial ℝ)
    (hP : ∀ n : ℕ, ∀ x : ℝ, x ^ k ≠ 1 →
      iteratedDeriv n (fun y : ℝ => 1 / (y ^ k - 1)) x =
        (P n).eval x / (x ^ k - 1) ^ (n + 1)) :
    ∀ n : ℕ, (P n).eval 1 = (-(k : ℝ)) ^ n * n.factorial := by
  sorry

end Putnam2002A1
