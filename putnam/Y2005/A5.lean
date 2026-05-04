import Mathlib

namespace Putnam2005A5

/-- Putnam 2005 A-5. Evaluate `∫₀¹ ln(x+1)/(x²+1) dx`. The value is
`(π / 8) ln 2`. -/
theorem putnam_2005_a5 :
    (∫ x in (0:ℝ)..1, Real.log (x + 1) / (x ^ 2 + 1)) =
      (Real.pi / 8) * Real.log 2 := by
  sorry

end Putnam2005A5
