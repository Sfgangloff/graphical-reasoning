import Mathlib

namespace Putnam2023B4

/-- Putnam 2023 B-4. For nonnegative integer `n` and a strictly
increasing sequence `t_0 < t_1 < ⋯ < t_n` of reals, let `f` satisfy
(a) `f` is continuous on `[t_0, ∞)` and twice differentiable away from
`t_1, …, t_n`,
(b) `f(t_0) = 1/2`,
(c) `lim_{t → t_k⁺} f'(t) = 0`,
(d) on `(t_k, t_{k+1})`, `f''(t) = k + 1`, and on `(t_n, ∞)`,
`f''(t) = n + 1`.
Subject to `t_k ≥ t_{k-1} + 1`, the least `T` with `f(t_0 + T) = 2023`
is `T = 29`. -/
theorem putnam_2023_b4 :
    sInf {T : ℝ | ∃ n : ℕ, ∃ t : ℕ → ℝ, ∃ f : ℝ → ℝ,
        StrictMonoOn t (Set.Iic n) ∧
        (∀ k ∈ Finset.Icc 1 n, t k ≥ t (k - 1) + 1) ∧
        ContinuousOn f (Set.Ici (t 0)) ∧
        f (t 0) = 1 / 2 ∧
        (∀ k ∈ Finset.Icc 0 n, Filter.Tendsto (deriv f)
          (nhdsWithin (t k) (Set.Ioi (t k))) (nhds 0)) ∧
        (∀ k ∈ Finset.range n, ∀ s ∈ Set.Ioo (t k) (t (k + 1)),
          iteratedDeriv 2 f s = k + 1) ∧
        (∀ s > t n, iteratedDeriv 2 f s = n + 1) ∧
        f (t 0 + T) = 2023} = 29 := by
  sorry

end Putnam2023B4
