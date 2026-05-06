import Mathlib

open Real MeasureTheory

/--
Putnam 2015 A1: Let A and B be points on the same branch of the hyperbola xy=1.
Suppose P is between A and B on this hyperbola such that the area of triangle APB
is maximal.  Then the region bounded by the hyperbola and the chord AP has the
same area as the region bounded by the hyperbola and the chord PB.

We parameterise points on the positive branch of `xy = 1` by their `x`-coordinate
`(t, 1/t)` with `t > 0`.  With `0 < a < p < b`:

* The triangle area at parameter `q` is
  `(1/2) * |a * (1/q - 1/b) + q * (1/b - 1/a) + b * (1/a - 1/q)|`.
* The chord through `(a, 1/a)` and `(p, 1/p)` is `y = 1/a + 1/p - x / (a*p)`,
  which lies above the curve `y = 1/x` for `x ∈ [a, p]`.  The bounded region's
  area is therefore `∫_a^p ((1/a + 1/p - x/(a p)) - 1/x) dx`.
-/
theorem putnam_2015_a1 :
    ∀ (a p b : ℝ), 0 < a → a < p → p < b →
      (∀ q : ℝ, a < q → q < b →
        (1/2) * |a * (1/q - 1/b) + q * (1/b - 1/a) + b * (1/a - 1/q)| ≤
        (1/2) * |a * (1/p - 1/b) + p * (1/b - 1/a) + b * (1/a - 1/p)|) →
      (∫ x in a..p, ((1/a + 1/p - x/(a*p)) - 1/x)) =
      (∫ x in p..b, ((1/p + 1/b - x/(b*p)) - 1/x)) := by
  sorry
