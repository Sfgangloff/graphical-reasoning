import Mathlib

namespace Putnam2008B2

/-- Putnam 2008 B-2. Define `F₀(x) = ln x` and
`F_{n+1}(x) = ∫₀^x F_n(t) dt` for `n ≥ 0`, `x > 0`. Then
`lim_{n → ∞} n! · F_n(1) / ln n = -1`. -/
theorem putnam_2008_b2
    (F : ℕ → ℝ → ℝ)
    (hF0 : F 0 = Real.log)
    (hF : ∀ n x, 0 < x → F (n + 1) x = ∫ t in (0:ℝ)..x, F n t) :
    Filter.Tendsto (fun n : ℕ => (n.factorial : ℝ) * F n 1 / Real.log n)
      Filter.atTop (nhds (-1)) := by
  sorry

end Putnam2008B2
