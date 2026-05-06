import Mathlib

open Filter Topology

private lemma split_sum_putnam_1994_a1 (N : ℕ) (f : ℕ → ℝ) :
    ∑ i ∈ Finset.range (2*N), f i = ∑ j ∈ Finset.range N, (f (2*j) + f (2*j+1)) := by
  induction N with
  | zero => simp
  | succ N ih =>
    rw [show 2 * (N+1) = (2*N) + 1 + 1 from by ring]
    rw [Finset.sum_range_succ, Finset.sum_range_succ]
    rw [Finset.sum_range_succ (fun j => f (2*j) + f (2*j+1)) N]
    rw [ih]
    ring

theorem putnam_1994_a1 (a : ℕ → ℝ)
    (ha : ∀ n ≥ 1, 0 < a n ∧ a n ≤ a (2*n) + a (2*n+1)) :
    ¬ ∃ L : ℝ, Tendsto (fun N : ℕ => ∑ n ∈ Finset.Icc 1 N, a n) atTop (𝓝 L) := by
  rintro ⟨L, hL⟩
  have h1 : 0 < a 1 := (ha 1 (by norm_num)).1
  -- Step 1: each block has sum ≥ a 1 (range form)
  have block_ge_range : ∀ k : ℕ, a 1 ≤ ∑ i ∈ Finset.range (2^k), a (2^k + i) := by
    intro k
    induction k with
    | zero => simp
    | succ k ih =>
      have eq1 : (2^(k+1) : ℕ) = 2 * 2^k := by ring
      rw [eq1]
      rw [split_sum_putnam_1994_a1 (2^k) (fun i => a (2 * 2^k + i))]
      apply le_trans ih
      apply Finset.sum_le_sum
      intros j _
      have hpow : (1 : ℕ) ≤ 2^k := Nat.one_le_two_pow
      have hj1 : 2^k + j ≥ 1 := by omega
      have h := (ha (2^k + j) hj1).2
      have e1 : (2 * 2 ^ k + 2 * j : ℕ) = 2 * (2^k + j) := by ring
      have e2 : (2 * 2 ^ k + (2 * j + 1) : ℕ) = 2 * (2^k + j) + 1 := by ring
      rw [e1, e2]
      exact h
  -- Step 2: convert to Ico
  have block_ge_Ico : ∀ k : ℕ, a 1 ≤ ∑ n ∈ Finset.Ico (2^k) (2^(k+1)), a n := by
    intro k
    have heq : ∑ n ∈ Finset.Ico (2^k) (2^(k+1)), a n
             = ∑ i ∈ Finset.range (2^k), a (2^k + i) := by
      rw [Finset.sum_Ico_eq_sum_range]
      have : (2^(k+1) : ℕ) - 2^k = 2^k := by
        have : (2^(k+1) : ℕ) = 2 * 2^k := by ring
        omega
      rw [this]
    rw [heq]
    exact block_ge_range k
  -- Step 3: total = sum of blocks
  have total_decomp : ∀ K : ℕ, ∑ n ∈ Finset.Ico 1 (2^(K+1)), a n =
      ∑ k ∈ Finset.range (K+1), ∑ n ∈ Finset.Ico (2^k) (2^(k+1)), a n := by
    intro K
    induction K with
    | zero => simp
    | succ K ih =>
      rw [Finset.sum_range_succ, ← ih]
      have h_le1 : 1 ≤ 2^(K+1) := Nat.one_le_two_pow
      have h_le2 : 2^(K+1) ≤ 2^(K+1+1) := by
        apply Nat.pow_le_pow_right (by norm_num); omega
      exact (Finset.sum_Ico_consecutive a h_le1 h_le2).symm
  -- Step 4: total ≥ (K+1) * a 1
  have total_ge : ∀ K : ℕ, ((K : ℝ) + 1) * a 1 ≤ ∑ n ∈ Finset.Ico 1 (2^(K+1)), a n := by
    intro K
    rw [total_decomp]
    have hcalc : ∑ k ∈ Finset.range (K+1), a 1 = ((K : ℝ) + 1) * a 1 := by
      rw [Finset.sum_const, Finset.card_range]
      push_cast
      ring
    rw [← hcalc]
    apply Finset.sum_le_sum
    intros k _
    exact block_ge_Ico k
  -- Step 5: partial sums are monotone and bounded by L (from Tendsto), contradiction
  have hmono : Monotone (fun N : ℕ => ∑ n ∈ Finset.Icc 1 N, a n) := by
    intros M N hMN
    apply Finset.sum_le_sum_of_subset_of_nonneg
    · intros n hn
      simp only [Finset.mem_Icc] at hn ⊢
      omega
    · intros n hn _
      simp only [Finset.mem_Icc] at hn
      exact (ha n hn.1).1.le
  have hbounded : ∀ N : ℕ, ∑ n ∈ Finset.Icc 1 N, a n ≤ L := hmono.ge_of_tendsto hL
  -- Pick K large enough
  obtain ⟨K, hK⟩ : ∃ K : ℕ, L < ((K : ℝ) + 1) * a 1 := by
    obtain ⟨K, hK⟩ := exists_nat_gt (L / a 1)
    refine ⟨K, ?_⟩
    have hdiv := (div_lt_iff₀ h1).mp hK
    have : (K : ℝ) * a 1 ≤ ((K : ℝ) + 1) * a 1 := by
      apply mul_le_mul_of_nonneg_right _ h1.le
      linarith
    linarith
  -- Convert Ico to Icc
  have hIco_Icc : Finset.Ico 1 (2^(K+1)) = Finset.Icc 1 (2^(K+1) - 1) := by
    ext x
    simp [Finset.mem_Ico, Finset.mem_Icc]
    have : (2 : ℕ)^(K+1) ≥ 1 := Nat.one_le_two_pow
    omega
  have hge := total_ge K
  rw [hIco_Icc] at hge
  have hbnd := hbounded (2^(K+1) - 1)
  linarith
