import Mathlib

open Topology Filter

namespace Putnam1985A3

/-- Sequence `a d m j`: starts at `d / 2^m`, with `a (j+1) = a j ^ 2 + 2 * a j`. -/
noncomputable def a (d : ℝ) (m : ℕ) : ℕ → ℝ
  | 0 => d / (2 : ℝ) ^ m
  | j + 1 => (a d m j) ^ 2 + 2 * a d m j

noncomputable abbrev putnam_1985_a3_solution : ℝ → ℝ := fun d => Real.exp d - 1

/-- Putnam 1985 A-3. Evaluate `lim_{n → ∞} a_n(n)`. -/
theorem putnam_1985_a3 (d : ℝ) :
    Tendsto (fun n : ℕ => a d n n) atTop (𝓝 (putnam_1985_a3_solution d)) := by
  sorry

end Putnam1985A3
