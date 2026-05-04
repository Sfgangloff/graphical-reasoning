import Mathlib

namespace Putnam2019A6

/-- Putnam 2019 A-6. Suppose `g : [0, 1] → ℝ` is continuous and twice
differentiable on `(0, 1)`, with `lim_{x → 0⁺} g(x) / x^r = 0` for some
`r > 1`. Then either `lim_{x → 0⁺} g'(x) = 0` or
`lim sup_{x → 0⁺} x^r |g''(x)| = ∞`. -/
theorem putnam_2019_a6
    (g : ℝ → ℝ) (r : ℝ) (hr : 1 < r)
    (hcont : ContinuousOn g (Set.Icc 0 1))
    (hdiff : ContDiffOn ℝ 2 g (Set.Ioo 0 1))
    (hlim : Filter.Tendsto (fun x => g x / x ^ r)
      (nhdsWithin 0 (Set.Ioi 0)) (nhds 0)) :
    Filter.Tendsto (deriv g) (nhdsWithin 0 (Set.Ioi 0)) (nhds 0) ∨
      Filter.limsup (fun x => x ^ r * |iteratedDeriv 2 g x|)
        (nhdsWithin 0 (Set.Ioi 0)) = ⊤ := by
  sorry

end Putnam2019A6
