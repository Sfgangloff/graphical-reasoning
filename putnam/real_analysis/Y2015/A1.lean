import Mathlib

namespace Putnam2015A1

/-- Putnam 2015 A-1. Let `A, B` be points on the same branch of
`x y = 1`, and let `P` lie between `A, B` on this branch and maximize
the area of `△A P B`. Then the regions cut off by the chords `A P`
and `P B` have equal areas. -/
theorem putnam_2015_a1
    (A B P : ℝ × ℝ)
    (hA : A.1 * A.2 = 1) (hAp : 0 < A.1)
    (hB : B.1 * B.2 = 1) (hBp : 0 < B.1)
    (hP : P.1 * P.2 = 1) (hPp : 0 < P.1)
    (hAB : A.1 < B.1) (hPmid : A.1 < P.1 ∧ P.1 < B.1)
    (hmax : ∀ Q : ℝ × ℝ, Q.1 * Q.2 = 1 → 0 < Q.1 →
      A.1 < Q.1 ∧ Q.1 < B.1 →
      |((B.1 - A.1) * (Q.2 - A.2) - (Q.1 - A.1) * (B.2 - A.2))| ≤
      |((B.1 - A.1) * (P.2 - A.2) - (P.1 - A.1) * (B.2 - A.2))|) :
    (∫ x in A.1..P.1, (1 / x - ((P.2 - A.2) / (P.1 - A.1) * (x - A.1) + A.2))) =
      (∫ x in P.1..B.1, (1 / x - ((B.2 - P.2) / (B.1 - P.1) * (x - P.1) + P.2))) := by
  sorry

end Putnam2015A1
