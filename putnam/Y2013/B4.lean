import Mathlib

namespace Putnam2013B4

/-- Putnam 2013 B-4. For continuous `f, g : [0,1] → ℝ`, with
`μ(f) = ∫₀¹ f`, `Var(f) = ∫₀¹ (f − μ(f))²`, `M(f) = max |f|`,
`Var(f g) ≤ 2 Var(f) M(g)² + 2 Var(g) M(f)²`. -/
theorem putnam_2013_b4
    (f g : ℝ → ℝ)
    (hf : ContinuousOn f (Set.Icc 0 1))
    (hg : ContinuousOn g (Set.Icc 0 1))
    (μ : (ℝ → ℝ) → ℝ) (hμ : ∀ h, μ h = ∫ x in (0:ℝ)..1, h x)
    (Var : (ℝ → ℝ) → ℝ)
    (hVar : ∀ h, Var h = ∫ x in (0:ℝ)..1, (h x - μ h) ^ 2)
    (M : (ℝ → ℝ) → ℝ)
    (hM : ∀ h, M h = sSup ((fun x => |h x|) '' Set.Icc 0 1)) :
    Var (fun x => f x * g x) ≤
      2 * Var f * (M g) ^ 2 + 2 * Var g * (M f) ^ 2 := by
  sorry

end Putnam2013B4
