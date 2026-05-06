import Mathlib

open Real MeasureTheory intervalIntegral

/-!
Putnam 2015 A1.

Let `A = (a, 1/a)` and `B = (b, 1/b)` lie on the same branch of `xy = 1`
(WLOG the positive branch, with `0 < a < b`).  Let `P = (p, 1/p)` lie
between `A` and `B`, i.e. `a < p < b`.  If `p` maximises the area of
triangle `APB`, then the regions enclosed by the chord `AP` (resp. `PB`)
and the hyperbola have equal area.
-/

theorem putnam_2015_a1
    (a b : ℝ) (ha : 0 < a) (hab : a < b) :
    let triArea : ℝ → ℝ := fun p =>
      (1/2) * |a * (1/p - 1/b) + p * (1/b - 1/a) + b * (1/a - 1/p)|
    let chordArea : ℝ → ℝ → ℝ := fun u v =>
      ∫ x in u..v, ((1/u + 1/v - x/(u*v)) - 1/x)
    ∀ p : ℝ, a < p → p < b →
      (∀ q : ℝ, a < q → q < b → triArea q ≤ triArea p) →
      chordArea a p = chordArea p b := by
  sorry
