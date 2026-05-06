import Mathlib

abbrev putnam_2004_a1_solution : Prop := True

theorem putnam_2004_a1 :
    (∀ (S : ℕ → ℕ),
      (∀ N : ℕ, S (N+1) = S N ∨ S (N+1) = S N + 1) →
      ∀ a b : ℕ, a < b → 5 * S a < 4 * a → 5 * S b > 4 * b →
        ∃ c : ℕ, a ≤ c ∧ c ≤ b ∧ 5 * S c = 4 * c)
    ↔ putnam_2004_a1_solution := by
  unfold putnam_2004_a1_solution
  refine iff_of_true ?_ trivial
  intro S hS a b hab ha hb
  set T : Finset ℕ := (Finset.Icc a b).filter (fun n => 5 * S n ≤ 4 * n) with hT_def
  have haT : a ∈ T := by
    simp only [hT_def, Finset.mem_filter, Finset.mem_Icc]
    refine ⟨⟨le_refl a, le_of_lt hab⟩, ?_⟩
    exact le_of_lt ha
  have hTne : T.Nonempty := ⟨a, haT⟩
  set m := T.max' hTne with hm_def
  have hmT : m ∈ T := T.max'_mem hTne
  have hm_props : a ≤ m ∧ m ≤ b ∧ 5 * S m ≤ 4 * m := by
    have h := Finset.mem_filter.mp hmT
    have h1 := Finset.mem_Icc.mp h.1
    exact ⟨h1.1, h1.2, h.2⟩
  have ham : a ≤ m := hm_props.1
  have hmb_le : m ≤ b := hm_props.2.1
  have hSm : 5 * S m ≤ 4 * m := hm_props.2.2
  have hmb : m < b := by
    rcases lt_or_eq_of_le hmb_le with h | h
    · exact h
    · exfalso
      rw [h] at hSm
      omega
  have hm1_in : m + 1 ∈ Finset.Icc a b := by
    rw [Finset.mem_Icc]
    exact ⟨le_trans ham (Nat.le_succ m), hmb⟩
  have hm1nT : m + 1 ∉ T := by
    intro h
    have hle : m + 1 ≤ m := Finset.le_max' T (m+1) h
    omega
  have h5Sm1 : 5 * S (m+1) > 4 * (m+1) := by
    by_contra hc
    push_neg at hc
    apply hm1nT
    rw [hT_def]
    exact Finset.mem_filter.mpr ⟨hm1_in, hc⟩
  rcases hS m with hstep | hstep
  · rw [hstep] at h5Sm1
    omega
  · rw [hstep] at h5Sm1
    refine ⟨m, ham, le_of_lt hmb, ?_⟩
    omega
