import Mathlib

namespace Putnam2021A2

/-- Putnam 2021 A-2. For positive real `x`, let
`g(x) = lim_{r → 0} ((x+1)^{r+1} − x^{r+1})^{1/r}`.
Then `lim_{x → ∞} g(x) / x = e`. -/
theorem putnam_2021_a2
    (g : ℝ → ℝ)
    (hg : ∀ x > 0, Filter.Tendsto
      (fun r : ℝ => ((x + 1) ^ (r + 1) - x ^ (r + 1)) ^ ((1 : ℝ) / r))
      (nhdsWithin 0 ({0}ᶜ)) (nhds (g x))) :
    Filter.Tendsto (fun x : ℝ => g x / x) Filter.atTop (nhds (Real.exp 1)) := by
  sorry

end Putnam2021A2
