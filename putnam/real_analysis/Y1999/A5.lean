import Mathlib

namespace Putnam1999A5

/-- Putnam 1999 A-5. There is a constant `C` such that for every real
polynomial `p` of degree 1999,
`|p(0)| ≤ C · ∫_{-1}^{1} |p(x)| dx`. -/
theorem putnam_1999_a5 :
    ∃ C : ℝ, ∀ p : Polynomial ℝ, p.natDegree = 1999 →
      |p.eval 0| ≤ C * ∫ x in (-1 : ℝ)..1, |p.eval x| := by
  sorry

end Putnam1999A5
