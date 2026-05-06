import Mathlib

abbrev putnam_2004_a1_solution : Prop := True

theorem putnam_2004_a1 :
  (∀ (S : ℕ → ℕ),
   (∀ n, S (n + 1) = S n ∨ S (n + 1) = S n + 1) →
   ∀ N₁ N₂ : ℕ, N₁ < N₂ → 5 * S N₁ < 4 * N₁ → 4 * N₂ < 5 * S N₂ →
   ∃ M, 5 * S M = 4 * M) ↔ putnam_2004_a1_solution := by
  refine iff_of_true ?_ trivial
  intro S hS N₁ N₂ hN hSN₁ hSN₂
  classical
  have hPex : ∃ n, N₁ < n ∧ 5 * S n ≥ 4 * n := ⟨N₂, hN, by omega⟩
  let c := Nat.find hPex
  have hc : N₁ < c ∧ 5 * S c ≥ 4 * c := Nat.find_spec hPex
  have hcmin : ∀ k < c, ¬ (N₁ < k ∧ 5 * S k ≥ 4 * k) :=
    fun k hk => Nat.find_min hPex hk
  obtain ⟨hcN1, hcS⟩ := hc
  have hcge1 : c ≥ 1 := by omega
  have hSc_step := hS (c - 1)
  have h_c_eq : c - 1 + 1 = c := Nat.sub_add_cancel hcge1
  rw [h_c_eq] at hSc_step
  have hSc1 : 5 * S (c - 1) < 4 * (c - 1) := by
    by_cases hcN1eq : c - 1 = N₁
    · rw [hcN1eq]; exact hSN₁
    · have hc1gt : N₁ < c - 1 := by omega
      have hnotP : ¬ (N₁ < (c - 1) ∧ 5 * S (c - 1) ≥ 4 * (c - 1)) :=
        hcmin (c - 1) (by omega)
      push_neg at hnotP
      exact hnotP hc1gt
  rcases hSc_step with h | h
  · rw [h] at hcS; omega
  · refine ⟨c, ?_⟩
    rw [h]
    omega
