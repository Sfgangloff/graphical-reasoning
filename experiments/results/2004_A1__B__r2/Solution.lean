import Mathlib

open Classical

abbrev putnam_2004_a1_solution : Prop := True

theorem putnam_2004_a1 :
    (∀ (S : ℕ → ℕ),
     (∀ N : ℕ, S (N + 1) = S N ∨ S (N + 1) = S N + 1) →
     ∀ (a b : ℕ),
     a < b →
     5 * S a < 4 * a →
     5 * S b > 4 * b →
     ∃ c : ℕ, a ≤ c ∧ c ≤ b ∧ 5 * S c = 4 * c) ↔ putnam_2004_a1_solution := by
  constructor
  · intro _; trivial
  · intro _ S hS a b hab ha hb
    -- Let P N := a ≤ N ∧ 5 * S N ≥ 4 * N. Take N* = least such N.
    let P : ℕ → Prop := fun N => a ≤ N ∧ 5 * S N ≥ 4 * N
    have hPb : P b := ⟨le_of_lt hab, le_of_lt hb⟩
    have hPdec : DecidablePred P := fun N => inferInstance
    let Nstar := Nat.find (p := P) ⟨b, hPb⟩
    have hNstar : P Nstar := Nat.find_spec (p := P) ⟨b, hPb⟩
    have hNstar_min : ∀ k < Nstar, ¬ P k :=
      fun k hk => Nat.find_min (p := P) ⟨b, hPb⟩ hk
    have hNstar_le_b : Nstar ≤ b := Nat.find_min' (p := P) ⟨b, hPb⟩ hPb
    obtain ⟨ha_le, hSlow⟩ := hNstar
    -- a < Nstar (since a ∉ P due to ha)
    have ha_lt : a < Nstar := by
      rcases lt_or_eq_of_le ha_le with h | h
      · exact h
      · exfalso
        rw [← h] at hSlow
        omega
    have hNs_pos : 1 ≤ Nstar := by omega
    -- Nstar - 1 ∉ P
    have hNm1_lt : Nstar - 1 < Nstar := by omega
    have hNotPm1 : ¬ P (Nstar - 1) := hNstar_min _ hNm1_lt
    have ha_le_m1 : a ≤ Nstar - 1 := by omega
    have hSm1 : 5 * S (Nstar - 1) < 4 * (Nstar - 1) := by
      by_contra h
      push_neg at h
      exact hNotPm1 ⟨ha_le_m1, h⟩
    have hsucc : Nstar - 1 + 1 = Nstar := by omega
    have hStep := hS (Nstar - 1)
    rw [hsucc] at hStep
    rcases hStep with h1 | h2
    · exfalso
      rw [h1] at hSlow
      -- 5 * S (Nstar-1) ≥ 4 * Nstar but 5 * S (Nstar-1) < 4 * (Nstar-1)
      have : 4 * (Nstar - 1) + 4 = 4 * Nstar := by omega
      omega
    · refine ⟨Nstar, by omega, hNstar_le_b, ?_⟩
      rw [h2]
      -- 5 * (S(Nstar-1) + 1) = 5*S(Nstar-1) + 5
      -- 5*S(Nstar-1) < 4*(Nstar-1) = 4*Nstar - 4, so 5*S(Nstar-1)+5 < 4*Nstar+1
      -- Combined with 5*S(Nstar-1)+5 ≥ 4*Nstar (since 5 * S Nstar ≥ 4 * Nstar)
      -- but 5 * S Nstar = 5 * S (Nstar-1) + 5
      -- Wait: hSlow currently uses S Nstar but we rewrote with h2.
      -- After rw [h2] the goal is 5 * (S (Nstar-1) + 1) = 4 * Nstar
      -- We still have hSlow : 5 * S Nstar ≥ 4 * Nstar but we modified it implicitly?
      -- Actually rw [h2] only rewrites in the goal, not hSlow.
      -- We need to combine the bounds.
      have hSlow' : 5 * (S (Nstar - 1) + 1) ≥ 4 * Nstar := by
        rw [← h2]; exact hSlow
      omega
