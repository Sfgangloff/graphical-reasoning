import Mathlib

namespace Putnam2019B4

/-- Putnam 2019 B-4. Let `ℱ` be the set of `f(x,y)` twice continuously
differentiable on `{x ≥ 1, y ≥ 1}` with
(a) `x f_x + y f_y = x y ln(x y)` and
(b) `x² f_{xx} + y² f_{yy} = x y`.
For each `f ∈ ℱ`, the value
`m(f) = inf_{s ≥ 1} (f(s+1, s+1) - f(s+1, s) - f(s, s+1) + f(s, s))`
equals `2 − 2 √2 / 3 + log 2`, independent of the choice of `f`. -/
theorem putnam_2019_b4
    (f : ℝ × ℝ → ℝ)
    (hf : ContDiffOn ℝ 2 f ({p : ℝ × ℝ | 1 ≤ p.1 ∧ 1 ≤ p.2}))
    (hfx : ∀ x y, 1 ≤ x → 1 ≤ y →
      x * (fderiv ℝ f (x, y)) (1, 0) + y * (fderiv ℝ f (x, y)) (0, 1) =
        x * y * Real.log (x * y))
    (hfxx : ∀ x y, 1 ≤ x → 1 ≤ y →
      x ^ 2 * iteratedFDeriv ℝ 2 f (x, y) ![(1, 0), (1, 0)] +
      y ^ 2 * iteratedFDeriv ℝ 2 f (x, y) ![(0, 1), (0, 1)] = x * y) :
    sInf {z : ℝ | ∃ s ≥ 1,
        z = f (s + 1, s + 1) - f (s + 1, s) - f (s, s + 1) + f (s, s)} =
      2 - 2 * Real.sqrt 2 / 3 + Real.log 2 := by
  sorry

end Putnam2019B4
