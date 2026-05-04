import Mathlib

open Real

namespace Putnam1986A3

/-- For `t ≥ 0`, `arccot t` is the unique `θ ∈ (0, π/2]` with `cot θ = t`. -/
noncomputable def arccot (t : ℝ) : ℝ := Real.pi / 2 - Real.arctan t

noncomputable abbrev putnam_1986_a3_solution : ℝ := Real.pi / 2

/-- Putnam 1986 A-3. Evaluate `∑_{n=0}^∞ arccot(n^2 + n + 1)`. -/
theorem putnam_1986_a3 :
    HasSum (fun n : ℕ => arccot ((n : ℝ) ^ 2 + n + 1)) putnam_1986_a3_solution := by
  sorry

end Putnam1986A3
