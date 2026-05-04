import Mathlib

namespace Putnam2014B6

/-- Putnam 2014 B-6. Let `f : [0,1] → ℝ` be Lipschitz with constant
`K`, and suppose for every rational `r ∈ [0,1]` there exist integers
`a, b` with `f(r) = a + b r`. Then `[0,1]` decomposes into finitely
many intervals on each of which `f` is linear. -/
theorem putnam_2014_b6
    (f : ℝ → ℝ) (K : ℝ) (hK : 0 < K)
    (hlip : ∀ x ∈ Set.Icc (0 : ℝ) 1, ∀ y ∈ Set.Icc (0 : ℝ) 1,
      |f x - f y| ≤ K * |x - y|)
    (hrat : ∀ r : ℚ, (r : ℝ) ∈ Set.Icc (0 : ℝ) 1 →
      ∃ a b : ℤ, f r = a + b * r) :
    ∃ n : ℕ, ∃ I : Fin n → Set ℝ,
      (∀ i, ∃ a b : ℝ, ∃ p q : ℝ, p ≤ q ∧ I i = Set.Icc p q) ∧
      Set.Icc (0 : ℝ) 1 = ⋃ i, I i ∧
      ∀ i, ∃ a b : ℝ, ∀ x ∈ I i, f x = a + b * x := by
  sorry

end Putnam2014B6
