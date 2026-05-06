import Mathlib

open Finset BigOperators

theorem putnam_1994_a1
    (a : ℕ → ℝ)
    (ha : ∀ n ≥ 1, 0 < a n ∧ a n ≤ a (2*n) + a (2*n+1)) :
    ¬ Summable a := by
  intro hsum
  have hpos : ∀ n, 1 ≤ n → 0 < a n := fun n hn => (ha n hn).1
  have hineq : ∀ n, 1 ≤ n → a n ≤ a (2*n) + a (2*n+1) := fun n hn => (ha n hn).2
  have h1pos : (0 : ℝ) < a 1 := hpos 1 le_rfl
  -- Key reindexing lemma: ∑ Ico N M (a (2m) + a (2m+1)) = ∑ Ico (2N) (2M) a n
  have key : ∀ N M : ℕ, N ≤ M →
      ∑ m ∈ Ico N M, (a (2*m) + a (2*m+1)) = ∑ n ∈ Ico (2*N) (2*M), a n := by
    intro N M hNM
    obtain ⟨d, rfl⟩ := Nat.exists_eq_add_of_le hNM
    clear hNM
    induction d with
    | zero => simp
    | succ d ih =>
      have hNd : N ≤ N + d := Nat.le_add_right N d
      have h2Nd : 2*N ≤ 2*(N+d) := by omega
      have h2Nd1 : 2*N ≤ 2*(N+d) + 1 := by omega
      rw [show N + (d+1) = (N+d) + 1 from by ring]
      rw [Finset.sum_Ico_succ_top hNd]
      rw [ih]
      rw [show 2*((N+d)+1) = (2*(N+d) + 1) + 1 from by ring]
      rw [Finset.sum_Ico_succ_top h2Nd1]
      rw [Finset.sum_Ico_succ_top h2Nd]
      ring
  -- T k+1 ≥ T k where T k = ∑ Ico (2^k) (2^(k+1)) a n
  have hTmono : ∀ k, (∑ n ∈ Ico (2^k) (2^(k+1)), a n) ≤
                     ∑ n ∈ Ico (2^(k+1)) (2^(k+2)), a n := by
    intro k
    have h2k : 1 ≤ 2^k := Nat.one_le_pow _ _ (by norm_num)
    have hineq2 : ∀ m ∈ Ico (2^k) (2^(k+1)), a m ≤ a (2*m) + a (2*m+1) := by
      intro m hm
      rw [mem_Ico] at hm
      exact hineq m (h2k.trans hm.1)
    have hpow : 2^k ≤ 2^(k+1) :=
      Nat.pow_le_pow_right (by norm_num) (Nat.le_succ _)
    calc ∑ n ∈ Ico (2^k) (2^(k+1)), a n
        ≤ ∑ m ∈ Ico (2^k) (2^(k+1)), (a (2*m) + a (2*m+1)) :=
          Finset.sum_le_sum hineq2
      _ = ∑ n ∈ Ico (2 * 2^k) (2 * 2^(k+1)), a n :=
          key (2^k) (2^(k+1)) hpow
      _ = ∑ n ∈ Ico (2^(k+1)) (2^(k+2)), a n := by
          have e1 : 2 * 2^k = 2^(k+1) := by rw [pow_succ]; ring
          have e2 : 2 * 2^(k+1) = 2^(k+2) := by rw [pow_succ]; ring
          rw [e1, e2]
  -- T 0 = a 1
  have hT0 : (∑ n ∈ Ico (2^0) (2^(0+1)), a n) = a 1 := by
    show (∑ n ∈ Ico 1 2, a n) = a 1
    rw [show (2 : ℕ) = 1 + 1 from rfl, Finset.sum_Ico_succ_top (le_refl 1)]
    simp
  -- T k ≥ a 1 for all k
  have hTbd : ∀ k, a 1 ≤ ∑ n ∈ Ico (2^k) (2^(k+1)), a n := by
    intro k
    induction k with
    | zero => exact hT0.ge
    | succ k ih => exact ih.trans (hTmono k)
  -- Use summability
  obtain ⟨S, hS⟩ := hsum
  have hSum := hS.tendsto_sum_nat
  rw [Metric.tendsto_atTop] at hSum
  obtain ⟨N₀, hN₀⟩ := hSum (a 1 / 2) (by linarith)
  obtain ⟨K, hK⟩ : ∃ K, N₀ ≤ 2^K := ⟨N₀, (Nat.lt_pow_self (by norm_num : 1 < 2)).le⟩
  have hKK1 : 2^K ≤ 2^(K+1) := Nat.pow_le_pow_right (by norm_num) (Nat.le_succ _)
  have hK1 : N₀ ≤ 2^(K+1) := hK.trans hKK1
  have h1 := hN₀ (2^K) hK
  have h2 := hN₀ (2^(K+1)) hK1
  -- (∑ < 2^(K+1)) - (∑ < 2^K) = ∑ Ico (2^K) (2^(K+1))
  have hdiff : (∑ n ∈ range (2^(K+1)), a n) - (∑ n ∈ range (2^K), a n) =
               ∑ n ∈ Ico (2^K) (2^(K+1)), a n := by
    rw [Finset.range_eq_Ico, Finset.range_eq_Ico]
    have h0K : (0 : ℕ) ≤ 2^K := Nat.zero_le _
    have hcons := Finset.sum_Ico_consecutive a h0K hKK1
    linarith
  have hTK := hTbd K
  rw [Real.dist_eq] at h1 h2
  have hab1 := abs_sub_lt_iff.mp h1
  have hab2 := abs_sub_lt_iff.mp h2
  have key2 : (∑ n ∈ range (2^(K+1)), a n) - (∑ n ∈ range (2^K), a n) < a 1 := by
    linarith [hab1.1, hab1.2, hab2.1, hab2.2]
  rw [hdiff] at key2
  linarith
