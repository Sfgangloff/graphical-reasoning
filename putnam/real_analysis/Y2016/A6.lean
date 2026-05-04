import Mathlib

namespace Putnam2016A6

/-- Putnam 2016 A-6. The smallest `C` such that for every real cubic
polynomial `P` with a root in `[0,1]`,
`∫₀¹ |P(x)| dx ≤ C · max_{x ∈ [0,1]} |P(x)|`,
is `C = 5/6`. -/
theorem putnam_2016_a6 :
    IsLeast
      {C : ℝ | ∀ P : Polynomial ℝ, P.natDegree = 3 →
        (∃ r ∈ Set.Icc (0 : ℝ) 1, P.eval r = 0) →
        (∫ x in (0:ℝ)..1, |P.eval x|) ≤
          C * sSup ((fun x => |P.eval x|) '' Set.Icc 0 1)}
      (5 / 6) := by
  sorry

end Putnam2016A6
