import Mathlib

open Finset

noncomputable def avgSeq : ℕ → ℕ → ℝ
  | 0, i => 1 / (i + 1 : ℝ)
  | j + 1, i => (avgSeq j i + avgSeq j (i + 1)) / 2

noncomputable def wsum (j i : ℕ) : ℝ :=
  ∑ k ∈ range (j + 1), (j.choose k : ℝ) / ((i : ℝ) + k + 1)

lemma wsum_zero (i : ℕ) : wsum 0 i = 1 / ((i:ℝ) + 1) := by
  simp [wsum]

-- General Pascal-style identity for sums weighted by binomial coefficients.
lemma pascal_sum (f : ℕ → ℝ) (j : ℕ) :
    ∑ k ∈ range (j+2), ((j+1).choose k : ℝ) * f k
    = (∑ k ∈ range (j+1), (j.choose k : ℝ) * f k)
      + (∑ k ∈ range (j+1), (j.choose k : ℝ) * f (k+1)) := by
  rw [show j + 2 = (j+1) + 1 from rfl,
      Finset.sum_range_succ' (fun k => ((j+1).choose k : ℝ) * f k) (j+1)]
  -- ∑ k ∈ range (j+1), C(j+1, k+1) * f(k+1) + C(j+1, 0) * f 0
  have step1 : ∀ k ∈ range (j+1),
      ((j+1).choose (k+1) : ℝ) * f (k+1)
      = (j.choose k : ℝ) * f (k+1) + (j.choose (k+1) : ℝ) * f (k+1) := by
    intros k _
    have h : ((j+1).choose (k+1) : ℕ) = j.choose k + j.choose (k+1) := Nat.choose_succ_succ j k
    have hcast : ((j+1).choose (k+1) : ℝ) = (j.choose k : ℝ) + (j.choose (k+1) : ℝ) := by
      exact_mod_cast h
    rw [hcast]
    ring
  rw [Finset.sum_congr rfl step1, Finset.sum_add_distrib]
  -- Now: A1 + A2 + C(j+1, 0) * f 0
  -- A1 := ∑ C(j,k) * f(k+1), A2 := ∑ C(j,k+1) * f(k+1)
  -- We want: B1 + B2 where B1 := ∑ C(j,k) * f k, B2 := ∑ C(j,k) * f(k+1) = A1
  -- So need: A2 + 1 * f 0 = B1
  have a2_eq : ∑ k ∈ range (j+1), (j.choose (k+1) : ℝ) * f (k+1)
             = (∑ k ∈ range (j+1), (j.choose k : ℝ) * f k) - 1 * f 0 := by
    rw [Finset.sum_range_succ (fun k => (j.choose (k+1) : ℝ) * f (k+1)) j]
    have h0 : j.choose (j+1) = 0 := Nat.choose_eq_zero_of_lt (Nat.lt_succ_self j)
    rw [Finset.sum_range_succ' (fun k => (j.choose k : ℝ) * f k) j]
    rw [h0, Nat.choose_zero_right]
    push_cast
    ring
  rw [a2_eq]
  rw [Nat.choose_zero_right]
  push_cast
  ring

lemma wsum_succ (j i : ℕ) : wsum (j+1) i = wsum j i + wsum j (i+1) := by
  unfold wsum
  have h := pascal_sum (fun k => 1 / ((i:ℝ) + (k:ℝ) + 1)) j
  -- Convert wsum (j+1) i form
  have lhs_eq : ∑ k ∈ range (j+1+1), (((j+1).choose k : ℝ) / ((i:ℝ) + (k:ℝ) + 1))
              = ∑ k ∈ range (j+2), (((j+1).choose k : ℝ) * (1 / ((i:ℝ) + (k:ℝ) + 1))) := by
    apply Finset.sum_congr rfl
    intros k _
    ring
  rw [lhs_eq, h]
  have eq1 : ∑ k ∈ range (j + 1), (j.choose k : ℝ) * (1 / ((i:ℝ) + (k:ℝ) + 1))
           = ∑ k ∈ range (j + 1), (j.choose k : ℝ) / ((i:ℝ) + (k:ℝ) + 1) := by
    apply Finset.sum_congr rfl; intros k _; ring
  have eq2 : ∑ k ∈ range (j + 1), (j.choose k : ℝ) * (1 / ((i:ℝ) + ((k+1):ℕ:ℝ) + 1))
           = ∑ k ∈ range (j + 1), (j.choose k : ℝ) / (((i+1):ℕ:ℝ) + (k:ℝ) + 1) := by
    apply Finset.sum_congr rfl; intros k _; push_cast; ring
  rw [eq1, eq2]

lemma avgSeq_eq_wsum (j : ℕ) : ∀ i, avgSeq j i = wsum j i / (2:ℝ)^j := by
  induction j with
  | zero =>
    intro i
    simp [avgSeq, wsum_zero, pow_zero]
  | succ j ih =>
    intro i
    rw [avgSeq, ih i, ih (i+1), wsum_succ]
    have hp : (2:ℝ)^j ≠ 0 := pow_ne_zero _ (by norm_num)
    have h2 : (2:ℝ)^(j+1) = 2 * 2^j := by ring
    rw [h2]
    field_simp
    ring

lemma sum_choose_div_add_one (n : ℕ) (hn : 0 < n) :
    ∑ k ∈ range n, ((n-1).choose k : ℝ) / ((k:ℝ) + 1) = ((2:ℝ)^n - 1) / (n:ℝ) := by
  obtain ⟨m, rfl⟩ : ∃ m, n = m + 1 := ⟨n - 1, by omega⟩
  simp only [Nat.add_sub_cancel]
  -- ∑_{k ∈ range(m+1)} C(m, k)/(k+1) = (2^(m+1) - 1)/(m+1)
  have key : ∀ k ∈ range (m+1),
      (m.choose k : ℝ) / ((k:ℝ) + 1) = ((m+1).choose (k+1) : ℝ) / ((m:ℝ) + 1) := by
    intros k _
    have h : (m + 1) * m.choose k = (k + 1) * (m + 1).choose (k + 1) := by
      have h1 := Nat.succ_mul_choose_eq m k
      -- h1 : Nat.succ m * Nat.choose m k = Nat.choose (Nat.succ m) (Nat.succ k) * Nat.succ k
      simp only [Nat.succ_eq_add_one] at h1
      linarith
    have hk : ((k:ℝ) + 1) ≠ 0 := by positivity
    have hm : ((m:ℝ) + 1) ≠ 0 := by positivity
    rw [div_eq_div_iff hk hm]
    have hcast : ((m+1) * m.choose k : ℕ) = ((k+1) * (m+1).choose (k+1) : ℕ) := h
    have : (((m+1) * m.choose k : ℕ) : ℝ) = (((k+1) * (m+1).choose (k+1) : ℕ) : ℝ) := by
      exact_mod_cast hcast
    push_cast at this
    linarith
  rw [Finset.sum_congr rfl key, ← Finset.sum_div]
  have shift : ∑ k ∈ range (m+1), ((m+1).choose (k+1) : ℝ)
             = (∑ k ∈ range (m+2), ((m+1).choose k : ℝ)) - 1 := by
    rw [show m+2 = (m+1)+1 from rfl,
        Finset.sum_range_succ' (fun k => ((m+1).choose k : ℝ)) (m+1)]
    push_cast [Nat.choose_zero_right]
    ring
  rw [shift]
  have sumChoose : ∑ k ∈ range (m+2), ((m+1).choose k : ℝ) = (2:ℝ)^(m+1) := by
    have h := Nat.sum_range_choose (m+1)
    have h2 : (∑ k ∈ range (m+1+1), ((m+1).choose k : ℝ)) = ((2^(m+1) : ℕ) : ℝ) := by
      push_cast
      exact_mod_cast h
    rw [show m+2 = m+1+1 from rfl, h2]
    push_cast
    ring
  rw [sumChoose]
  push_cast
  ring

theorem putnam_2003_b2 (n : ℕ) (hn : 1 ≤ n) : avgSeq (n - 1) 0 < 2 / n := by
  rw [avgSeq_eq_wsum]
  unfold wsum
  have hn1 : n - 1 + 1 = n := by omega
  rw [hn1]
  have eq1 : ∀ k ∈ range n,
      ((n-1).choose k : ℝ) / (((0:ℕ):ℝ) + (k:ℝ) + 1) = ((n-1).choose k : ℝ) / ((k:ℝ) + 1) := by
    intros k _
    push_cast
    ring_nf
  rw [Finset.sum_congr rfl eq1, sum_choose_div_add_one n hn]
  have hn0 : (n : ℝ) > 0 := by exact_mod_cast hn
  have h2pos : (0:ℝ) < (2:ℝ)^(n-1) := by positivity
  have h2n : (2:ℝ)^n = 2 * 2^(n-1) := by
    have : n = (n-1) + 1 := by omega
    rw [this, pow_succ]; ring
  -- Goal: (2^n - 1) / n / 2^(n-1) < 2 / n
  rw [div_div]
  -- Goal: (2^n - 1) / (n * 2^(n-1)) < 2 / n
  have hne : (n:ℝ) ≠ 0 := ne_of_gt hn0
  have h2ne : ((2:ℝ)^(n-1)) ≠ 0 := ne_of_gt h2pos
  rw [div_lt_iff (by positivity : (0:ℝ) < (n:ℝ) * 2^(n-1))]
  -- Goal: 2^n - 1 < 2/n * (n * 2^(n-1))
  have simp_rhs : (2:ℝ) / n * ((n:ℝ) * 2^(n-1)) = 2 * 2^(n-1) := by
    field_simp
  rw [simp_rhs]
  linarith [h2n]
