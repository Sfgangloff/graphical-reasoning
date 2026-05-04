import Mathlib

open MeasureTheory Filter Topology

namespace Putnam1989B3

/-- Closed-form factor: `μₙ = solution n · μ₀`, where the factor is
`(n! / 3^n) · ∏_{k=1}^n 2^k / (2^k − 1)`. -/
noncomputable abbrev putnam_1989_b3_solution : ℕ → ℝ :=
  fun n => (n.factorial : ℝ) / 3 ^ n *
    ∏ k ∈ Finset.range n, (2 ^ (k + 1) : ℝ) / (2 ^ (k + 1) - 1)

/-- Putnam 1989 B-3. The function `f` on `[0, ∞)` satisfies
`f'(x) = -3 f(x) + 6 f(2x)` and `|f(x)| ≤ e^{-√x}`. The moments
`μₙ = ∫₀^∞ xⁿ f(x) dx` satisfy `μₙ = solution n · μ₀`, and the
sequence `μₙ · 3^n / n!` converges, with limit `0` only if `μ₀ = 0`. -/
theorem putnam_1989_b3 (f : ℝ → ℝ) (μ : ℕ → ℝ)
    (hf : Differentiable ℝ f)
    (hode : ∀ x > 0, deriv f x = -3 * f x + 6 * f (2 * x))
    (hbound : ∀ x ≥ 0, |f x| ≤ Real.exp (-Real.sqrt x))
    (hμ : ∀ n, μ n = ∫ x in Set.Ioi (0 : ℝ), x ^ n * f x) :
    (∀ n, μ n = putnam_1989_b3_solution n * μ 0) ∧
    (∃ L, Tendsto (fun n : ℕ => μ n * 3 ^ n / n.factorial) atTop (𝓝 L) ∧
      (L = 0 ↔ μ 0 = 0)) := by
  sorry

end Putnam1989B3
