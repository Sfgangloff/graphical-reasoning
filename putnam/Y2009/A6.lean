import Mathlib

namespace Putnam2009A6

/-- Putnam 2009 A-6. Let `f : [0,1]² → ℝ` be continuous with continuous
partial derivatives on `(0,1)²`. Set `a = ∫₀¹ f(0,y) dy`,
`b = ∫₀¹ f(1,y) dy`, `c = ∫₀¹ f(x,0) dx`, `d = ∫₀¹ f(x,1) dx`. Then there
need not exist `(x₀, y₀) ∈ (0,1)²` with `∂f/∂x = b - a` and
`∂f/∂y = d - c`. (Disprove.) -/
theorem putnam_2009_a6 :
    ¬ ∀ (f : ℝ × ℝ → ℝ),
      ContinuousOn f (Set.Icc 0 1 ×ˢ Set.Icc 0 1) →
      ContDiffOn ℝ 1 f (Set.Ioo 0 1 ×ˢ Set.Ioo 0 1) →
      ∃ x₀ ∈ Set.Ioo (0:ℝ) 1, ∃ y₀ ∈ Set.Ioo (0:ℝ) 1,
        (fderiv ℝ f (x₀, y₀)) (1, 0) =
            (∫ y in (0:ℝ)..1, f (1, y)) - (∫ y in (0:ℝ)..1, f (0, y)) ∧
        (fderiv ℝ f (x₀, y₀)) (0, 1) =
            (∫ x in (0:ℝ)..1, f (x, 1)) - (∫ x in (0:ℝ)..1, f (x, 0)) := by
  sorry

end Putnam2009A6
