import Mathlib

open Polynomial

noncomputable def putnam_2002_a1_solution : ℕ → ℕ → ℝ :=
  fun k n => (-(k : ℝ))^n * n.factorial

theorem putnam_2002_a1
    (k : ℕ) (P : ℕ → Polynomial ℝ) (kpos : k > 0)
    (Pderiv : ∀ n : ℕ, ∀ x : ℝ, x^k ≠ 1 →
      iteratedDeriv n (fun y : ℝ => 1 / (y^k - 1)) x =
        (P n).eval x / (x^k - 1)^(n+1)) :
    ∀ n : ℕ, (P n).eval 1 = putnam_2002_a1_solution k n := by
  sorry
