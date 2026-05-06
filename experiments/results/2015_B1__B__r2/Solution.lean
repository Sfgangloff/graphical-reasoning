import Mathlib

open Set

/-- Putnam 2015 B1: If f is three times differentiable on ℝ and has at least
five distinct real zeros, then f + 6f' + 12f'' + 8f''' has at least two
distinct real zeros.

Proof sketch: Let g(x) = exp(x/2) * f(x). One verifies that
8 * g'''(x) = exp(x/2) * (f + 6f' + 12f'' + 8f''')(x). Since exp > 0,
zeros of g coincide with zeros of f, and zeros of g''' coincide with
zeros of f + 6f' + 12f'' + 8f'''. Apply Rolle's theorem 3 times:
g has 5 zeros ⇒ g' has 4 zeros ⇒ g'' has 3 zeros ⇒ g''' has 2 zeros.
-/
theorem putnam_2015_b1
    (f : ℝ → ℝ)
    (hf : ContDiff ℝ 3 f)
    (hz : ∃ S : Finset ℝ, S.card = 5 ∧ ∀ x ∈ S, f x = 0) :
    ∃ T : Finset ℝ, T.card = 2 ∧ ∀ x ∈ T,
      f x + 6 * deriv f x + 12 * deriv (deriv f) x + 8 * deriv (deriv (deriv f)) x = 0 := by
  sorry
