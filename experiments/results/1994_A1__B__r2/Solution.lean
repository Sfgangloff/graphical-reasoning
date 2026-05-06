import Mathlib

open Finset

theorem putnam_1994_a1
    (a : ℕ → ℝ)
    (ha : ∀ n ≥ 1, 0 < a n ∧ a n ≤ a (2 * n) + a (2 * n + 1)) :
    ¬ Summable a := by
  intro hsum
  have hpos1 : 0 < a 1 := (ha 1 (by norm_num)).1
  have hineq : ∀ n, 1 ≤ n → a n ≤ a (2 * n) + a (2 * n + 1) :=
    fun n hn => (ha n hn).2
  -- Step 1: Reindex lemma
  have reindex : ∀ N : ℕ,
      ∑ n ∈ Finset.Ico 1 (N+1), (a (2*n) + a (2*n+1)) =
      ∑ m ∈ Finset.Ico 2 (2*N+2), a m := by
    intro N
    induction N with
    | zero => simp
    | succ k ih =>
      rw [show k + 1 + 1 = (k+1) + 1 from rfl,
          Finset.sum_Ico_succ_top (Nat.succ_le_succ (Nat.zero_le k)), ih,
          show 2 * (k + 1) + 2 = (2*k + 3) + 1 from by ring,
          Finset.sum_Ico_succ_top (by omega : 2 ≤ 2*k + 3),
          show (2 * k + 3 : ℕ) = (2*k + 2) + 1 from rfl,
          Finset.sum_Ico_succ_top (by omega : 2 ≤ 2*k + 2)]
      ring
  -- Step 2: Key inequality (Ico form)
  have key : ∀ N : ℕ,
      a 1 + ∑ n ∈ Finset.Ico 1 (N+1), a n ≤ ∑ m ∈ Finset.Ico 1 (2*N+2), a m := by
    intro N
    have hsplit : Finset.Ico 1 (2*N+2) = insert 1 (Finset.Ico 2 (2*N+2)) := by
      ext k
      simp only [Finset.mem_Ico, Finset.mem_insert]
      omega
    have hnotmem : 1 ∉ Finset.Ico 2 (2*N+2) := by simp [Finset.mem_Ico]
    rw [hsplit, Finset.sum_insert hnotmem, ← reindex N]
    apply add_le_add_left
    apply Finset.sum_le_sum
    intro n hn
    rw [Finset.mem_Ico] at hn
    exact hineq n hn.1
  -- Step 3: Convert to Range form
  have key_range : ∀ N : ℕ,
      a 1 + ∑ n ∈ Finset.range (N+1), a n ≤ ∑ m ∈ Finset.range (2*N+2), a m := by
    intro N
    have hr1 : ∑ n ∈ Finset.range (N+1), a n = a 0 + ∑ n ∈ Finset.Ico 1 (N+1), a n := by
      have heq : Finset.range (N+1) = insert 0 (Finset.Ico 1 (N+1)) := by
        ext k
        simp only [Finset.mem_range, Finset.mem_Ico, Finset.mem_insert]
        omega
      rw [heq, Finset.sum_insert (by simp [Finset.mem_Ico])]
    have hr2 : ∑ n ∈ Finset.range (2*N+2), a n = a 0 + ∑ n ∈ Finset.Ico 1 (2*N+2), a n := by
      have heq : Finset.range (2*N+2) = insert 0 (Finset.Ico 1 (2*N+2)) := by
        ext k
        simp only [Finset.mem_range, Finset.mem_Ico, Finset.mem_insert]
        omega
      rw [heq, Finset.sum_insert (by simp [Finset.mem_Ico])]
    rw [hr1, hr2]
    have := key N
    linarith
  -- Step 4: Iteration: ∀ k, a 0 + k * a 1 ≤ S_{2^k}
  have iter : ∀ k : ℕ, a 0 + (k : ℝ) * a 1 ≤ ∑ n ∈ Finset.range (2^k), a n := by
    intro k
    induction k with
    | zero =>
      simp [pow_zero, Finset.sum_range_one]
    | succ k ih =>
      have hpow1 : (1:ℕ) ≤ 2^k := Nat.one_le_two_pow
      have hpow_eq : (2:ℕ)^(k+1) = 2 * (2^k - 1) + 2 := by
        have h := Nat.one_le_two_pow (n := k)
        have : 2 * 2^k = 2 * ((2^k - 1) + 1) := by
          congr 1
          omega
        rw [pow_succ]
        omega
      have h2k1 : (2:ℕ)^k - 1 + 1 = 2^k := by
        have := Nat.one_le_two_pow (n := k)
        omega
      rw [hpow_eq]
      have hk := key_range (2^k - 1)
      rw [h2k1] at hk
      push_cast
      linarith
  -- Step 5: Tendency
  have htendsto : Filter.Tendsto (fun N => ∑ n ∈ Finset.range N, a n) Filter.atTop
      (nhds (∑' n, a n)) := hsum.hasSum.tendsto_sum_nat
  -- Subsequence S_{2^k} also tends to L
  have h2k_tendsto : Filter.Tendsto (fun k : ℕ => (2:ℕ)^k) Filter.atTop Filter.atTop := by
    rw [Filter.tendsto_atTop_atTop]
    intro b
    refine ⟨b, fun n hn => ?_⟩
    calc b ≤ n := hn
      _ ≤ 2^n := Nat.lt_two_pow_self.le
  have hsub : Filter.Tendsto (fun k => ∑ n ∈ Finset.range (2^k), a n) Filter.atTop
      (nhds (∑' n, a n)) := htendsto.comp h2k_tendsto
  -- Step 6: k * a 1 → ∞
  have hkinf : Filter.Tendsto (fun k : ℕ => (k : ℝ) * a 1) Filter.atTop Filter.atTop := by
    have h1 : Filter.Tendsto (fun k : ℕ => (k : ℝ)) Filter.atTop Filter.atTop :=
      Filter.tendsto_natCast_atTop_atTop
    exact h1.atTop_mul_const hpos1
  -- Step 7: Contradiction
  have hev1 : ∀ᶠ k in Filter.atTop, ∑ n ∈ Finset.range (2^k), a n ≤ (∑' n, a n) + 1 :=
    hsub.eventually_le_const (by linarith)
  have hev2 : ∀ᶠ k in Filter.atTop, (k : ℝ) * a 1 > (∑' n, a n) + 1 - a 0 :=
    hkinf.eventually_gt_atTop _
  have hcontra : ∀ᶠ k in Filter.atTop, False := by
    filter_upwards [hev1, hev2] with k hk1 hk2
    have hi := iter k
    linarith
  rw [Filter.eventually_atTop] at hcontra
  obtain ⟨k, hk⟩ := hcontra
  exact hk k (le_refl k)
