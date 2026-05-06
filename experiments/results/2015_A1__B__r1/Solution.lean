import Mathlib

open Real MeasureTheory intervalIntegral

/-
Putnam 2015 A1.  Let A and B be points on the same branch of xy = 1.
Let P be a point on the hyperbola lying between A and B such that the
area of triangle APB is as large as possible.  Show that the regions
bounded by the hyperbola and the chord AP and the hyperbola and the
chord PB have equal areas.

We parametrize the (positive) branch by a, p, b > 0 with a < p < b, and
encode "P maximises the triangle area" as the inequality on the doubled
signed area expression `f q := a*(1/q - 1/b) + q*(1/b - 1/a) + b*(1/a - 1/q)`.
On (a,b) this expression is positive (vanishing at the endpoints), so the
absolute value condition simplifies and the maximum forces `p^2 = a*b`.
-/

theorem putnam_2015_a1
    (a b p : ℝ) (ha : 0 < a) (hap : a < p) (hpb : p < b)
    (hmax : ∀ q : ℝ, a < q → q < b →
      |a * (1/q - 1/b) + q * (1/b - 1/a) + b * (1/a - 1/q)| ≤
      |a * (1/p - 1/b) + p * (1/b - 1/a) + b * (1/a - 1/p)|) :
    ∫ x in a..p, ((a + p - x) / (a * p) - 1/x) =
    ∫ x in p..b, ((p + b - x) / (p * b) - 1/x) := by
  sorry
