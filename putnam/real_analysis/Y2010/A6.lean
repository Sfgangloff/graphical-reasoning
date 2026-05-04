import Mathlib

namespace Putnam2010A6

/-- Putnam 2010 A-6. If `f : [0, ∞) → ℝ` is strictly decreasing and
continuous with `f x → 0` as `x → ∞`, then
`∫₀^∞ (f(x) − f(x+1)) / f(x) dx` diverges. -/
theorem putnam_2010_a6
    (f : ℝ → ℝ)
    (hcont : ContinuousOn f (Set.Ici 0))
    (hmono : StrictAntiOn f (Set.Ici 0))
    (hpos : ∀ x ≥ 0, 0 < f x)
    (hlim : Filter.Tendsto f Filter.atTop (nhds 0)) :
    ¬ ∃ L : ℝ,
        Filter.Tendsto
          (fun B : ℝ => ∫ x in (0:ℝ)..B, (f x - f (x + 1)) / f x)
          Filter.atTop (nhds L) := by
  sorry

end Putnam2010A6
