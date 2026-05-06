import Mathlib

open Filter Topology BigOperators

noncomputable def putnam_2014_a3_solution : ℝ := 3/7

theorem putnam_2014_a3
  (a : ℕ → ℝ)
  (ha0 : a 0 = 5/2)
  (hak : ∀ k ≥ 1, a k = (a (k-1))^2 - 2) :
  Tendsto (fun N => ∏ k ∈ Finset.range N, (1 - 1/(a k))) atTop
    (𝓝 putnam_2014_a3_solution) := by
  sorry
