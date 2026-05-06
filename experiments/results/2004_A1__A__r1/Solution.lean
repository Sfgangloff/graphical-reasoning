import Mathlib

abbrev putnam_2004_a1_solution : Prop := True

theorem putnam_2004_a1 :
    putnam_2004_a1_solution ↔
    (∀ (S : ℕ → ℕ) (N₁ N₂ : ℕ),
      (∀ n, S (n + 1) = S n ∨ S (n + 1) = S n + 1) →
      N₁ ≤ N₂ →
      5 * S N₁ < 4 * N₁ →
      5 * S N₂ > 4 * N₂ →
      ∃ N, 5 * S N = 4 * N) := by
  refine ⟨fun _ => ?_, fun _ => trivial⟩
  intro S N₁ N₂ hS hN h1 h2
  suffices h : ∀ k : ℕ, ∀ M : ℕ,
      5 * S M < 4 * M → 5 * S (M + k) > 4 * (M + k) → ∃ N, 5 * S N = 4 * N by
    obtain ⟨k, hk⟩ : ∃ k, N₂ = N₁ + k := ⟨N₂ - N₁, by omega⟩
    rw [hk] at h2
    exact h k N₁ h1 h2
  intro k
  induction k with
  | zero =>
    intros M hm1 hm2
    simp only [Nat.add_zero] at hm2
    omega
  | succ k ih =>
    intros M hm1 hm2
    by_cases hk : 5 * S (M + k) > 4 * (M + k)
    · exact ih M hm1 hk
    · push_neg at hk
      have heq2 : M + (k + 1) = M + k + 1 := by ring
      rw [heq2] at hm2
      rcases hS (M + k) with hs | hs
      · rw [hs] at hm2
        omega
      · rw [hs] at hm2
        exact ⟨M + k, by omega⟩
