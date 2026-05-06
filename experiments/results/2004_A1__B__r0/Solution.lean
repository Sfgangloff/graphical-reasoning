import Mathlib

abbrev putnam_2004_a1_solution : Prop := True

theorem putnam_2004_a1 :
    (∀ (S : ℕ → ℕ),
      (∀ n, S (n + 1) = S n ∨ S (n + 1) = S n + 1) →
      ∀ a b : ℕ, a ≤ b → 5 * S a < 4 * a → 4 * b < 5 * S b →
        ∃ c, a ≤ c ∧ c ≤ b ∧ 5 * S c = 4 * c) ↔ putnam_2004_a1_solution := by
  unfold putnam_2004_a1_solution
  refine ⟨fun _ => trivial, fun _ => ?_⟩
  intro S hS a b hab hSa hSb
  classical
  let P : ℕ → Prop := fun n => a ≤ n ∧ n ≤ b ∧ 4 * n ≤ 5 * S n
  have hex : ∃ n, P n := ⟨b, hab, le_refl b, le_of_lt hSb⟩
  let c := Nat.find hex
  have hPc : P c := Nat.find_spec hex
  obtain ⟨hac, hcb, hSc⟩ := hPc
  have hcgt : c > a := by
    rcases lt_or_eq_of_le hac with h | h
    · exact h
    · exfalso
      have : 4 * a ≤ 5 * S a := by rw [h]; exact hSc
      omega
  have hc1ge : a ≤ c - 1 := by omega
  have hc1le : c - 1 ≤ b := by omega
  have hPc1 : ¬ P (c - 1) := Nat.find_min hex (by omega : c - 1 < c)
  have hSc1 : 5 * S (c - 1) < 4 * (c - 1) := by
    by_contra h
    push_neg at h
    exact hPc1 ⟨hc1ge, hc1le, h⟩
  have hcsucc : (c - 1) + 1 = c := by omega
  have hStep := hS (c - 1)
  rw [hcsucc] at hStep
  refine ⟨c, hac, hcb, ?_⟩
  rcases hStep with heq | heq
  · rw [heq] at hSc; omega
  · rw [heq] at hSc; omega
