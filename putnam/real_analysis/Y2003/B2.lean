import Mathlib

namespace Putnam2003B2

open scoped BigOperators

/-- Putnam 2003 B-2. Starting from `1, 1/2, 1/3, …, 1/n`, repeatedly
form the sequence of averages of consecutive entries until a single
real number `x_n` remains. Then `x_n < 2/n`. -/
theorem putnam_2003_b2
    (avg : ∀ {k : ℕ}, (Fin k → ℝ) → Fin (k - 1) → ℝ)
    (havg : ∀ {k : ℕ} (s : Fin k → ℝ) (i : Fin (k - 1)),
      avg s i = (s ⟨i.val, by omega⟩ + s ⟨i.val + 1, by omega⟩) / 2)
    (iter : ∀ (k : ℕ), (Fin k → ℝ) → ℕ → (Σ m, Fin m → ℝ))
    (hbase : ∀ k (s : Fin k → ℝ), iter k s 0 = ⟨k, s⟩)
    (hstep : ∀ k (s : Fin k → ℝ) j,
      iter k s (j + 1) =
        ⟨(iter k s j).1 - 1, fun i => avg (iter k s j).2 i⟩) :
    ∀ n : ℕ, 1 ≤ n →
      ∀ x : ℝ,
      (∃ s : Fin 1 → ℝ, iter n (fun i : Fin n => 1 / (i.val + 1 : ℝ)) (n - 1) =
          ⟨1, s⟩ ∧ s 0 = x) →
        x < 2 / n := by
  sorry

end Putnam2003B2
