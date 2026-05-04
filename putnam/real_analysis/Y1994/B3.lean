import Mathlib

namespace Putnam1994B3

abbrev putnam_1994_b3_solution : Set ℝ := Set.Iio 1

/-- Putnam 1994 B-3. Find the set of real numbers `k` such that for every
positive differentiable `f : ℝ → ℝ` with `f'(x) > f(x)` for all `x`, there
is some `N` such that `f(x) > exp(k x)` for all `x > N`.
The answer is `k < 1`. -/
theorem putnam_1994_b3 :
    {k : ℝ | ∀ f : ℝ → ℝ, Differentiable ℝ f → (∀ x, 0 < f x) →
      (∀ x, deriv f x > f x) →
      ∃ N : ℝ, ∀ x > N, f x > Real.exp (k * x)} = putnam_1994_b3_solution := by
  sorry

end Putnam1994B3
