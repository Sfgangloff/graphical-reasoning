import Mathlib

namespace Putnam1995A5

/-- Putnam 1995 A-5. Let `x₁,…,xₙ` be differentiable real functions of `t`
solving the linear system `x'ᵢ(t) = ∑ⱼ aᵢⱼ xⱼ(t)` with all `aᵢⱼ > 0`,
and assume each `xᵢ(t) → 0` as `t → ∞`. Then `x₁,…,xₙ` are linearly
dependent (as functions `ℝ → ℝ`). -/
theorem putnam_1995_a5
    (n : ℕ) (hn : 1 ≤ n)
    (a : Fin n → Fin n → ℝ) (x : Fin n → ℝ → ℝ)
    (hapos : ∀ i j, 0 < a i j)
    (hdiff : ∀ i, Differentiable ℝ (x i))
    (hsys : ∀ i, ∀ t, deriv (x i) t = ∑ j, a i j * x j t)
    (hlim : ∀ i, Filter.Tendsto (x i) Filter.atTop (nhds 0)) :
    ¬ LinearIndependent ℝ x := by
  sorry

end Putnam1995A5
