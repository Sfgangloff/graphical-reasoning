import Mathlib

namespace Putnam1992A4

/-- Solution: `f^{(k)}(0) = (−1)^{k/2} · k!` if `k` is even, else `0`. -/
noncomputable abbrev putnam_1992_a4_solution : ℕ → ℝ :=
  fun k => if Even k then (-1) ^ (k / 2) * (k.factorial : ℝ) else 0

/-- Putnam 1992 A-4. Let `f` be infinitely differentiable on `ℝ` with
`f(1/n) = n² / (n² + 1)` for every `n ≥ 1`. Compute `f^{(k)}(0)`. -/
theorem putnam_1992_a4 (f : ℝ → ℝ)
    (hf : ContDiff ℝ ⊤ f)
    (hcond : ∀ n : ℕ+, f (1 / (n : ℝ)) = (n : ℝ) ^ 2 / ((n : ℝ) ^ 2 + 1)) :
    ∀ k, iteratedDeriv k f 0 = putnam_1992_a4_solution k := by
  sorry

end Putnam1992A4
