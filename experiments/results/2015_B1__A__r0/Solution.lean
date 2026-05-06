import Mathlib

open Real

theorem putnam_2015_b1
    (f : ℝ → ℝ)
    (hf : ContDiff ℝ 3 f)
    (hzeros : ∃ s : Finset ℝ, s.card ≥ 5 ∧ ∀ x ∈ s, f x = 0) :
    ∃ s : Finset ℝ, s.card ≥ 2 ∧ ∀ x ∈ s,
      f x + 6 * (deriv f) x + 12 * (deriv (deriv f)) x + 8 * (deriv (deriv (deriv f))) x = 0 := by
  sorry
