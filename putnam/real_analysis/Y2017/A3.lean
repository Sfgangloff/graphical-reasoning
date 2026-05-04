import Mathlib

namespace Putnam2017A3

/-- Putnam 2017 A-3. Let `a < b` be reals and `f, g : [a,b] → (0, ∞)`
continuous with `∫_a^b f = ∫_a^b g` but `f ≠ g`. Define
`I_n = ∫_a^b f^{n+1}/g^n`. Then `(I_n)` is increasing and `I_n → ∞`. -/
theorem putnam_2017_a3
    (a b : ℝ) (hab : a < b) (f g : ℝ → ℝ)
    (hf : ContinuousOn f (Set.Icc a b)) (hg : ContinuousOn g (Set.Icc a b))
    (hfp : ∀ x ∈ Set.Icc a b, 0 < f x) (hgp : ∀ x ∈ Set.Icc a b, 0 < g x)
    (hint : (∫ x in a..b, f x) = ∫ x in a..b, g x)
    (hne : ∃ x ∈ Set.Icc a b, f x ≠ g x) :
    let I : ℕ → ℝ := fun n => ∫ x in a..b, (f x) ^ (n + 1) / (g x) ^ n
    StrictMono I ∧ Filter.Tendsto I Filter.atTop Filter.atTop := by
  sorry

end Putnam2017A3
