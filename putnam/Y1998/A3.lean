import Mathlib

namespace Putnam1998A3

/-- Putnam 1998 A-3. If `f : ℝ → ℝ` has continuous third derivative,
there is a point `a ∈ ℝ` with
`f(a) · f'(a) · f''(a) · f'''(a) ≥ 0`. -/
theorem putnam_1998_a3
    (f : ℝ → ℝ) (hf : ContDiff ℝ 3 f) :
    ∃ a : ℝ,
      0 ≤ f a * deriv f a * iteratedDeriv 2 f a * iteratedDeriv 3 f a := by
  sorry

end Putnam1998A3
