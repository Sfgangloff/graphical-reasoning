import Mathlib

namespace Putnam1993B4

/-- Putnam 1993 B-4. If `K` is positive and continuous on `[0,1]²`, `f`, `g`
positive and continuous on `[0,1]`, with
`∫₀¹ f(y) K(x,y) dy = g(x)` and `∫₀¹ g(y) K(x,y) dy = f(x)` for all
`x ∈ [0,1]`, then `f = g` on `[0,1]`. -/
theorem putnam_1993_b4
    (K : ℝ → ℝ → ℝ) (f g : ℝ → ℝ)
    (hKpos : ∀ x ∈ Set.Icc (0 : ℝ) 1, ∀ y ∈ Set.Icc (0 : ℝ) 1, 0 < K x y)
    (hKcont : ContinuousOn (fun p : ℝ × ℝ => K p.1 p.2)
                (Set.Icc (0 : ℝ) 1 ×ˢ Set.Icc (0 : ℝ) 1))
    (hfpos : ∀ x ∈ Set.Icc (0 : ℝ) 1, 0 < f x)
    (hgpos : ∀ x ∈ Set.Icc (0 : ℝ) 1, 0 < g x)
    (hfcont : ContinuousOn f (Set.Icc 0 1))
    (hgcont : ContinuousOn g (Set.Icc 0 1))
    (hfg : ∀ x ∈ Set.Icc (0 : ℝ) 1, ∫ y in (0 : ℝ)..1, f y * K x y = g x)
    (hgf : ∀ x ∈ Set.Icc (0 : ℝ) 1, ∫ y in (0 : ℝ)..1, g y * K x y = f x) :
    ∀ x ∈ Set.Icc (0 : ℝ) 1, f x = g x := by
  sorry

end Putnam1993B4
