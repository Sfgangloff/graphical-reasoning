import Mathlib

open Real MeasureTheory intervalIntegral

/-!
Putnam 2015 A1.

Let A and B be points on the same branch of the hyperbola xy = 1. Let P
be a point lying between A and B on this hyperbola, such that the area
of triangle APB is as large as possible. Show that the region bounded
by the hyperbola and the chord AP has the same area as the region
bounded by the hyperbola and the chord PB.

We formalize the case of the positive branch (the negative branch case
is analogous by the symmetry (x, y) ↦ (-x, -y) of the curve). The
points are A = (a, 1/a), B = (b, 1/b), P = (p, 1/p) with 0 < a < p < b.
The (signed) doubled triangle area is
  (p - a) * (1/b - 1/a) - (b - a) * (1/p - 1/a).
The chord from (s, 1/s) to (t, 1/t) is the line
  y = 1/s + 1/t - x/(s*t),
so the area of the region between the hyperbola and chord on [s, t] is
  ∫ x in s..t, ((1/s + 1/t - x/(s*t)) - 1/x).
-/

theorem putnam_2015_a1
    (a b p : ℝ)
    (ha : 0 < a)
    (hab : a < b)
    (hap : a < p)
    (hpb : p < b)
    (hmax : ∀ q : ℝ, a < q → q < b →
      |(q - a) * (1/b - 1/a) - (b - a) * (1/q - 1/a)| ≤
      |(p - a) * (1/b - 1/a) - (b - a) * (1/p - 1/a)|) :
    ∫ x in a..p, ((1/a + 1/p - x/(a*p)) - 1/x) =
    ∫ x in p..b, ((1/p + 1/b - x/(p*b)) - 1/x) := by
  sorry
