import Mathlib

open Filter Topology

noncomputable def putnam_2014_a3_solution : ℝ := 3 / 7

theorem putnam_2014_a3
    (a : ℕ → ℝ)
    (ha0 : a 0 = 5 / 2)
    (hak : ∀ k, a (k + 1) = (a k) ^ 2 - 2) :
    Tendsto (fun n => ∏ k ∈ Finset.range n, (1 - 1 / a k)) atTop
      (𝓝 putnam_2014_a3_solution) := by
  sorry
