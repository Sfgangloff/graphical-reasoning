import Mathlib

namespace Putnam2012A3

/-- Putnam 2012 A-3. There is a unique continuous `f : [-1, 1] → ℝ`
with
(i) `f(x) = ((2 − x²)/2) · f(x²/(2 − x²))` for all `x ∈ [-1,1]`,
(ii) `f(0) = 1`, and
(iii) `lim_{x → 1⁻} f(x)/√(1 − x)` exists and is finite.
The function is `f(x) = √(1 − x²) · π / 2` (modulo a normalization). -/
theorem putnam_2012_a3 :
    ∃! f : ℝ → ℝ,
      ContinuousOn f (Set.Icc (-1) 1) ∧
        (∀ x ∈ Set.Icc (-1 : ℝ) 1,
          f x = ((2 - x ^ 2) / 2) * f (x ^ 2 / (2 - x ^ 2))) ∧
        f 0 = 1 ∧
        ∃ L : ℝ,
          Filter.Tendsto (fun x : ℝ => f x / Real.sqrt (1 - x))
            (nhdsWithin 1 (Set.Iio 1)) (nhds L) := by
  sorry

end Putnam2012A3
