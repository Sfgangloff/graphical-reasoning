import Mathlib

namespace Putnam2011B3

/-- Putnam 2011 B-3. Let `f, g` be real-valued functions on an open
interval around `0` with `g` continuous and nonzero at `0`. If `f g`
and `f / g` are differentiable at `0`, must `f` be differentiable at
`0`? Yes. -/
theorem putnam_2011_b3
    (U : Set ℝ) (hU : IsOpen U) (h0 : (0 : ℝ) ∈ U)
    (f g : ℝ → ℝ)
    (hg_cont : ContinuousAt g 0) (hg_ne : g 0 ≠ 0)
    (hfg_diff : DifferentiableAt ℝ (fun x => f x * g x) 0)
    (hfdg_diff : DifferentiableAt ℝ (fun x => f x / g x) 0) :
    DifferentiableAt ℝ f 0 := by
  sorry

end Putnam2011B3
