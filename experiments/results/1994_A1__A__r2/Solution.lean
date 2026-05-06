import Mathlib

open Finset BigOperators

private lemma sum_Ico_two_mul_eq (f : ℕ → ℝ) :
    ∀ b a, a ≤ b →
      ∑ n ∈ Finset.Ico a b, (f (2*n) + f (2*n+1)) = ∑ m ∈ Finset.Ico (2*a) (2*b), f m := by
  intro b
  induction b with
  | zero =>
    intro a hab
    interval_cases a
    simp
  | succ b ih =>
    intro a hab
    rcases Nat.lt_or_ge a (b+1) with hlt | hge
    · have hab' : a ≤ b := Nat.lt_succ_iff.mp hlt
      rw [Finset.sum_Ico_succ_top hab']
      have h2b1 : 2 * a ≤ 2 * b + 1 := by linarith
      have h2b : 2 * a ≤ 2 * b := by linarith
      rw [show 2 * (b + 1) = 2 * b + 1 + 1 from by ring]
      rw [Finset.sum_Ico_succ_top h2b1]
      rw [Finset.sum_Ico_succ_top h2b]
      rw [ih a hab']
      ring
    · have ha_eq : a = b + 1 := le_antisymm hab hge
      subst ha_eq
      simp

theorem putnam_1994_a1
    (a : ℕ → ℝ)
    (ha : ∀ n ≥ 1, 0 < a n ∧ a n ≤ a (2*n) + a (2*n+1)) :
    ¬ Summable a := by
  have ha_pos : ∀ n, 1 ≤ n → 0 < a n := fun n hn => (ha n hn).1
  have ha_ineq : ∀ n, 1 ≤ n → a n ≤ a (2*n) + a (2*n+1) := fun n hn => (ha n hn).2
  have ha1_pos : 0 < a 1 := ha_pos 1 le_rfl
  -- T k = ∑_{n ∈ [2^k, 2^(k+1))} a n
  set T : ℕ → ℝ := fun k => ∑ n ∈ Finset.Ico (2^k) (2^(k+1)), a n with hT_def
  -- T 0 = a 1
  have hT0 : T 0 = a 1 := by
    show ∑ n ∈ Finset.Ico ((2:ℕ)^0) ((2:ℕ)^1), a n = a 1
    rw [show ((2:ℕ)^0 : ℕ) = 1 from rfl, show ((2:ℕ)^1 : ℕ) = 2 from rfl]
    rw [Finset.sum_Ico_succ_top (le_refl 1)]
    simp
  -- T k ≤ T (k+1)
  have hT_le_succ : ∀ k, T k ≤ T (k+1) := by
    intro k
    have h2k_pos : 1 ≤ (2:ℕ)^k := Nat.one_le_pow _ _ (by norm_num)
    have h_eq : T (k+1) = ∑ n ∈ Finset.Ico (2^k) (2^(k+1)), (a (2*n) + a (2*n+1)) := by
      show ∑ m ∈ Finset.Ico ((2:ℕ)^(k+1)) ((2:ℕ)^(k+2)), a m = _
      have h1 : (2:ℕ)^(k+1) = 2 * 2^k := by rw [pow_succ]; ring
      have h2 : (2:ℕ)^(k+2) = 2 * 2^(k+1) := by rw [pow_succ]; ring
      rw [h1, h2, h1]
      symm
      apply sum_Ico_two_mul_eq
      omega
    rw [h_eq]
    apply Finset.sum_le_sum
    intro n hn
    apply ha_ineq
    have := (Finset.mem_Ico.mp hn).1
    linarith
  -- T k ≥ a 1
  have hT_ge : ∀ k, a 1 ≤ T k := by
    intro k
    induction k with
    | zero => exact le_of_eq hT0.symm
    | succ k ih => exact ih.trans (hT_le_succ k)
  -- ∑ n ∈ Ico 1 (2^(K+1)), a n = ∑ k ∈ range (K+1), T k
  have hsplit : ∀ K, ∑ n ∈ Finset.Ico 1 (2^(K+1)), a n = ∑ k ∈ Finset.range (K+1), T k := by
    intro K
    induction K with
    | zero =>
      show ∑ n ∈ Finset.Ico 1 ((2:ℕ)^1), a n = ∑ k ∈ Finset.range 1, T k
      rw [show ((2:ℕ)^1 : ℕ) = 2 from rfl]
      rw [Finset.sum_range_one]
      rw [hT0]
      rw [Finset.sum_Ico_succ_top (le_refl 1)]
      simp
    | succ K ih =>
      rw [Finset.sum_range_succ, ← ih]
      have h1le : 1 ≤ (2:ℕ)^(K+1) := Nat.one_le_pow _ _ (by norm_num)
      have hle : (2:ℕ)^(K+1) ≤ (2:ℕ)^(K+2) :=
        Nat.pow_le_pow_right (by norm_num) (by omega)
      show ∑ n ∈ Finset.Ico 1 ((2:ℕ)^(K+2)), a n =
        ∑ n ∈ Finset.Ico 1 ((2:ℕ)^(K+1)), a n + T (K+1)
      rw [← Finset.sum_Ico_consecutive a h1le hle]
  -- (K+1) * a 1 ≤ ∑ n ∈ Ico 1 (2^(K+1)), a n
  have h_partial : ∀ K : ℕ, ((K : ℝ) + 1) * a 1 ≤ ∑ n ∈ Finset.Ico 1 (2^(K+1)), a n := by
    intro K
    rw [hsplit]
    have hsum_le : ∑ k ∈ Finset.range (K+1), a 1 ≤ ∑ k ∈ Finset.range (K+1), T k := by
      apply Finset.sum_le_sum
      intros k _
      exact hT_ge k
    rw [Finset.sum_const, Finset.card_range, nsmul_eq_mul] at hsum_le
    have : ((K + 1 : ℕ) : ℝ) = (K : ℝ) + 1 := by push_cast; ring
    rw [this] at hsum_le
    exact hsum_le
  -- Contradiction: assume Summable a, derive bounded partial sums.
  intro hsum
  have hsum' : Summable (fun n => a (n+1)) := (summable_nat_add_iff 1).mpr hsum
  have hpos' : ∀ n, 0 ≤ a (n+1) :=
    fun n => le_of_lt (ha_pos (n+1) (Nat.succ_le_succ (Nat.zero_le n)))
  -- ∑ n ∈ range N, a (n+1) ≤ ∑' n, a (n+1)
  set M : ℝ := ∑' n, a (n+1) with hM_def
  have hHas : HasSum (fun n => a (n+1)) M := hsum'.hasSum
  have hbdd : ∀ N, ∑ n ∈ Finset.range N, a (n+1) ≤ M :=
    fun N => sum_le_hasSum (Finset.range N) (fun n _ => hpos' n) hHas
  -- ∑ n ∈ range N, a (n+1) = ∑ n ∈ Ico 1 (N+1), a n
  have hconv : ∀ N, ∑ n ∈ Finset.range N, a (n+1) = ∑ n ∈ Finset.Ico 1 (N+1), a n := by
    intro N
    rw [Finset.sum_Ico_eq_sum_range]
    rw [show N + 1 - 1 = N from by omega]
    apply Finset.sum_congr rfl
    intros k _
    rw [Nat.add_comm]
  -- Key: (K+1) * a 1 ≤ M for all K
  have hkey : ∀ K : ℕ, ((K : ℝ) + 1) * a 1 ≤ M := by
    intro K
    have h1 : 1 ≤ (2:ℕ)^(K+1) := Nat.one_le_pow _ _ (by norm_num)
    have hN : 2^(K+1) - 1 + 1 = 2^(K+1) := by omega
    have h2 := hbdd (2^(K+1) - 1)
    rw [hconv, hN] at h2
    exact (h_partial K).trans h2
  -- But (K+1) * a 1 → ∞, contradicting hkey.
  obtain ⟨K, hK⟩ : ∃ K : ℕ, M / a 1 < K := exists_nat_gt (M / a 1)
  have hKR : M / a 1 < ((K:ℝ) + 1) := by
    have : (K : ℝ) ≤ (K : ℝ) + 1 := by linarith
    exact lt_of_lt_of_le hK this
  rw [div_lt_iff₀ ha1_pos] at hKR
  exact absurd (hkey K) (not_le.mpr hKR)
