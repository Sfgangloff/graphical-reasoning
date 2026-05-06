import Mathlib

abbrev putnam_2004_a1_solution : Prop := True

theorem putnam_2004_a1 :
    (∀ (S : ℕ → ℕ), (∀ n, S (n+1) = S n ∨ S (n+1) = S n + 1) →
      ∀ N1 N2 : ℕ, N1 < N2 → 5 * S N1 < 4 * N1 → 5 * S N2 > 4 * N2 →
      ∃ N : ℕ, N1 ≤ N ∧ N ≤ N2 ∧ 5 * S N = 4 * N) ↔ putnam_2004_a1_solution := by
  classical
  constructor
  · intro _
    trivial
  · intro _ S hS N1 N2 hN12 h1 h2
    set P : ℕ → Prop := fun N => N1 ≤ N ∧ N ≤ N2 ∧ 5 * S N ≥ 4 * N with hPdef
    have hexists : ∃ N, P N := ⟨N2, le_of_lt hN12, le_refl _, le_of_lt h2⟩
    let N := Nat.find hexists
    have hN_spec : P N := Nat.find_spec hexists
    obtain ⟨hN_ge, hN_le, hN_ineq⟩ := hN_spec
    have hN_gt_N1 : N > N1 := by
      rcases lt_or_eq_of_le hN_ge with h | h
      · exact h
      · exfalso
        rw [← h] at hN_ineq
        omega
    have hNm1_ge_N1 : N - 1 ≥ N1 := by omega
    have hNm1_le_N2 : N - 1 ≤ N2 := by omega
    have hNm1_lt_N : N - 1 < N := by omega
    have hNm1_not : ¬ P (N - 1) := Nat.find_min hexists hNm1_lt_N
    have hNm1_ineq : 5 * S (N - 1) < 4 * (N - 1) := by
      by_contra hc
      push_neg at hc
      exact hNm1_not ⟨hNm1_ge_N1, hNm1_le_N2, hc⟩
    have hNeq : N = (N - 1) + 1 := by omega
    have hStep : S N = S (N - 1) ∨ S N = S (N - 1) + 1 := by
      have := hS (N - 1)
      rw [← hNeq] at this
      exact this
    rcases hStep with hS0 | hS1
    · exfalso
      rw [hS0] at hN_ineq
      have h4N : 4 * (N - 1) + 4 = 4 * N := by omega
      omega
    · refine ⟨N, le_of_lt hN_gt_N1, hN_le, ?_⟩
      rw [hS1]
      have h4N : 4 * (N - 1) + 4 = 4 * N := by omega
      have h_lower : 5 * (S (N - 1) + 1) ≥ 4 * N := by
        rw [← hS1]; exact hN_ineq
      omega
