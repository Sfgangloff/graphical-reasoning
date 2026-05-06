import Mathlib

open scoped BigOperators

/-!
# Putnam 2003 B2

Starting with `1, 1/2, …, 1/n`, repeatedly average neighbors until one number `x_n`
remains. Show `x_n < 2/n`.

The closed form is `x_n = (2^n - 1) / (n * 2^(n-1)) = 2/n - 1/(n * 2^(n-1)) < 2/n`.

Key formula (provable by induction on `k` using Pascal's rule):
  `a k i = (1/2^k) * Σ_{j=0}^k C(k,j) / (i+j+1)`

Then `a (n-1) 0 = (1/2^(n-1)) * Σ_{j=0}^{n-1} C(n-1,j)/(j+1)`.
Using `C(n-1,j)/(j+1) = C(n,j+1)/n` and `Σ_{j=0}^{n-1} C(n,j+1) = 2^n - 1`,
we get `a (n-1) 0 = (2^n - 1) / (n * 2^(n-1)) < 2/n`.
-/

theorem putnam_2003_b2
    (n : ℕ) (hn : 0 < n)
    (a : ℕ → ℕ → ℝ)
    (h0 : ∀ i, i < n → a 0 i = 1 / (i + 1 : ℝ))
    (h1 : ∀ k i, k + 1 < n → i + k + 1 < n →
      a (k+1) i = (a k i + a k (i+1)) / 2) :
    a (n-1) 0 < 2 / n := by
  sorry
