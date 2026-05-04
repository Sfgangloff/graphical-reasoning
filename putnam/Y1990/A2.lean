import Mathlib

open Filter Topology

namespace Putnam1990A2

abbrev putnam_1990_a2_solution : Prop := True

/-- Putnam 1990 A-2. Is `√2` the limit of a sequence of numbers of the
form `∛n − ∛m` with `n, m ∈ ℕ`? -/
theorem putnam_1990_a2 :
    (∃ s : ℕ → ℕ × ℕ,
        Tendsto (fun k => ((s k).1 : ℝ) ^ ((1 : ℝ) / 3)
            - ((s k).2 : ℝ) ^ ((1 : ℝ) / 3))
          atTop (𝓝 (Real.sqrt 2)))
      ↔ putnam_1990_a2_solution := by
  sorry

end Putnam1990A2
