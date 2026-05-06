import Mathlib

open Finset BigOperators Topology

theorem putnam_1994_a1 (a : ℕ → ℝ)
    (ha : ∀ n ≥ 1, 0 < a n ∧ a n ≤ a (2*n) + a (2*n+1)) :
    ¬ Summable a := by
  -- Step 1: ∑[2A, 2B) f = ∑[A, B) (f(2n) + f(2n+1)).
  have hpair : ∀ A B : ℕ, ∑ i ∈ Ico (2*A) (2*B), a i =
      ∑ n ∈ Ico A B, (a (2*n) + a (2*n+1)) := by
    intro A B
    by_cases hAB : A ≤ B
    · induction B, hAB using Nat.le_induction with
      | base => simp
      | succ B hAB ih =>
        rw [show (2 * (B + 1) : ℕ) = 2 * B + 2 by ring]
        rw [Finset.sum_Ico_succ_top hAB]
        rw [show (2 * B + 2 : ℕ) = (2 * B + 1) + 1 by ring]
        rw [Finset.sum_Ico_succ_top (by omega : 2*A ≤ 2*B + 1)]
        rw [Finset.sum_Ico_succ_top (by omega : 2*A ≤ 2*B)]
        rw [ih]
        ring
    · have h1 : ¬ A < B := by omega
      have h2 : ¬ 2*A < 2*B := by omega
      rw [Finset.Ico_eq_empty h1, Finset.Ico_eq_empty h2]
      simp
  -- Step 2: For k ≥ 0, sum over [2^k, 2^(k+1)) is bounded below by a 1.
  have key : ∀ k : ℕ, a 1 ≤ ∑ i ∈ Ico (2^k) (2^(k+1)), a i := by
    intro k
    induction k with
    | zero =>
      have heq : (Ico (2^0) (2^1) : Finset ℕ) = {1} := by
        ext x; simp only [mem_Ico, mem_singleton]; omega
      rw [heq]
      simp
    | succ k ih =>
      have hpos : (1 : ℕ) ≤ 2^k := Nat.one_le_two_pow
      calc a 1 ≤ ∑ i ∈ Ico (2^k) (2^(k+1)), a i := ih
        _ ≤ ∑ i ∈ Ico (2^k) (2^(k+1)), (a (2*i) + a (2*i+1)) := by
            apply Finset.sum_le_sum
            intro i hi
            rw [mem_Ico] at hi
            exact (ha i (by omega)).2
        _ = ∑ j ∈ Ico (2^(k+1)) (2^(k+2)), a j := by
            rw [show (2^(k+1) : ℕ) = 2 * 2^k by ring]
            rw [show (2^(k+2) : ℕ) = 2 * 2^(k+1) by ring]
            rw [show (2^(k+1) : ℕ) = 2 * 2^k by ring]
            exact (hpair (2^k) (2 * 2^k)).symm
  -- Step 3: ∑ i ∈ Ico 1 (2^(K+1)), a i ≥ (K+1) * a 1.
  have hbound : ∀ K : ℕ, (K + 1 : ℝ) * a 1 ≤ ∑ i ∈ Ico 1 (2^(K+1)), a i := by
    intro K
    induction K with
    | zero =>
      have heq : (Ico 1 (2^1) : Finset ℕ) = {1} := by
        ext x; simp only [mem_Ico, mem_singleton]; omega
      rw [heq]
      simp
    | succ K ih =>
      have h1 : (1 : ℕ) ≤ 2^(K+1) := Nat.one_le_two_pow
      have h2 : (2^(K+1) : ℕ) ≤ 2^(K+1+1) :=
        Nat.pow_le_pow_right (by norm_num) (Nat.le_succ _)
      have hsplit : ∑ i ∈ Ico 1 (2^(K+1+1)), a i =
          ∑ i ∈ Ico 1 (2^(K+1)), a i + ∑ i ∈ Ico (2^(K+1)) (2^(K+1+1)), a i :=
        (Finset.sum_Ico_consecutive a h1 h2).symm
      rw [hsplit]
      have hk1 := key (K+1)
      have alg : (((K + 1 : ℕ) : ℝ) + 1) * a 1 = ((K : ℝ) + 1) * a 1 + a 1 := by
        push_cast; ring
      linarith [ih, hk1, alg]
  -- Step 4: Derive contradiction.
  intro hsum
  have ha1pos : (0 : ℝ) < a 1 := (ha 1 (by omega)).1
  obtain ⟨L, hL⟩ := hsum
  have hpartial : Filter.Tendsto (fun N => ∑ i ∈ range N, a i) Filter.atTop (𝓝 L) :=
    hL.tendsto_sum_nat
  have hbdd : BddAbove (Set.range (fun N => ∑ i ∈ range N, a i)) :=
    hpartial.bddAbove_range
  obtain ⟨B, hB⟩ := hbdd
  obtain ⟨K, hK⟩ := exists_nat_gt ((B - a 0 + 1) / a 1)
  have hKbig : (B - a 0 + 1 : ℝ) < (K + 1) * a 1 := by
    have h1 : (B - a 0 + 1) / a 1 < K + 1 := by linarith
    have h2 : ((B - a 0 + 1) / a 1) * a 1 < (K + 1) * a 1 :=
      mul_lt_mul_of_pos_right h1 ha1pos
    rwa [div_mul_cancel₀ _ (ne_of_gt ha1pos)] at h2
  have hbnd1 := hbound K
  have hge : (B - a 0 + 1 : ℝ) < ∑ i ∈ Ico 1 (2^(K+1)), a i := by linarith
  have h2pow : 1 ≤ 2^(K+1) := Nat.one_le_two_pow
  have hrange_split : ∑ i ∈ range (2^(K+1)), a i = a 0 + ∑ i ∈ Ico 1 (2^(K+1)), a i := by
    have hset : range (2^(K+1)) = insert 0 (Ico 1 (2^(K+1))) := by
      ext x
      simp only [Finset.mem_range, Finset.mem_insert, Finset.mem_Ico]
      omega
    rw [hset, Finset.sum_insert (by simp)]
  have hUB : ∑ i ∈ range (2^(K+1)), a i ≤ B := hB ⟨2^(K+1), rfl⟩
  rw [hrange_split] at hUB
  linarith
