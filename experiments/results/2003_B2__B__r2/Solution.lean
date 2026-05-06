import Mathlib

open Finset BigOperators

namespace Putnam2003B2Aux

/-- The averaging operator on infinite sequences. -/
noncomputable def avg (b : ℕ → ℝ) : ℕ → ℝ := fun i => (b i + b (i + 1)) / 2

/-- Closed form for iterated averaging: after k iterations, the value at position j is
a binomially weighted average of the original values at positions j, j+1, ..., j+k. -/
lemma avg_iter (a : ℕ → ℝ) (k j : ℕ) :
    avg^[k] a j = (1 / (2:ℝ)^k) * ∑ l ∈ Finset.range (k+1), (k.choose l : ℝ) * a (j+l) := by
  induction k generalizing j with
  | zero => simp [avg]
  | succ k ih =>
    rw [Function.iterate_succ_apply']
    show (avg^[k] a j + avg^[k] a (j+1)) / 2 = _
    rw [ih j, ih (j+1)]
    -- Reindex shift sum: ∑ C(k,l) a(j+1+l) = ∑ C(k,l) a(j+(l+1))
    have shift : ∑ l ∈ Finset.range (k+1), (k.choose l : ℝ) * a (j + 1 + l) =
        ∑ l ∈ Finset.range (k+1), (k.choose l : ℝ) * a (j + (l+1)) := by
      apply Finset.sum_congr rfl
      intro l _
      congr 2
      ring
    rw [shift]
    -- Pascal-like combine
    have pascal : ∀ l, ((k+1).choose (l+1) : ℝ) = (k.choose l : ℝ) + (k.choose (l+1) : ℝ) := by
      intro l
      have := Nat.choose_succ_succ' k l
      exact_mod_cast this
    -- Now reorganize. We want:
    -- ((1/2^k) S1 + (1/2^k) S2) / 2 = (1/2^(k+1)) T
    -- where S1 = ∑_{l=0..k} C(k,l) a(j+l)
    --       S2 = ∑_{l=0..k} C(k,l) a(j+(l+1))
    --       T  = ∑_{l=0..k+1} C(k+1,l) a(j+l)
    -- Equivalent: S1 + S2 = T
    -- T = a(j) + ∑_{l=0..k-1} C(k+1,l+1) a(j+(l+1)) + a(j+(k+1))
    --   = a(j) + ∑_{l=0..k-1} (C(k,l) + C(k,l+1)) a(j+(l+1)) + a(j+(k+1))
    -- S1 = a(j) + ∑_{l=0..k-1} C(k,l+1) a(j+(l+1))
    -- S2 = ∑_{l=0..k-1} C(k,l) a(j+(l+1)) + a(j+(k+1))
    -- S1 + S2 = a(j) + ∑_{l=0..k-1} (C(k,l) + C(k,l+1)) a(j+(l+1)) + a(j+(k+1))  ✓
    have hT : ∑ l ∈ Finset.range (k+2), ((k+1).choose l : ℝ) * a (j+l) =
        a j + (∑ l ∈ Finset.range k, ((k+1).choose (l+1) : ℝ) * a (j + (l+1))) + a (j + (k+1)) := by
      rw [show k + 2 = (k + 1) + 1 from rfl, Finset.sum_range_succ]
      rw [Finset.sum_range_succ' (fun l => ((k+1).choose l : ℝ) * a (j+l)) k]
      have hself : ((k+1).choose (k+1) : ℝ) = 1 := by
        rw [show ((k+1).choose (k+1) : ℝ) = ((1 : ℕ) : ℝ) from by rw [Nat.choose_self]]
        simp
      simp [hself]
      ring
    have hS1 : ∑ l ∈ Finset.range (k+1), (k.choose l : ℝ) * a (j+l) =
        a j + ∑ l ∈ Finset.range k, (k.choose (l+1) : ℝ) * a (j + (l+1)) := by
      rw [Finset.sum_range_succ' (fun l => (k.choose l : ℝ) * a (j+l)) k]
      simp [add_comm]
    have hS2 : ∑ l ∈ Finset.range (k+1), (k.choose l : ℝ) * a (j + (l+1)) =
        (∑ l ∈ Finset.range k, (k.choose l : ℝ) * a (j + (l+1))) + a (j + (k+1)) := by
      rw [Finset.sum_range_succ]
      simp
    -- Compute LHS = (1/2^k * S1 + 1/2^k * S2)/2 = (S1+S2)/(2*2^k) = T/2^(k+1)
    rw [hS1, hS2, hT]
    simp_rw [pascal]
    have h2pow : (2:ℝ)^(k+1) = 2 * 2^k := by ring
    rw [h2pow]
    have h2k : (2:ℝ)^k ≠ 0 := pow_ne_zero _ (by norm_num)
    field_simp
    have hcomb : ∑ x ∈ Finset.range k, (((k.choose x : ℝ) + (k.choose (x+1) : ℝ)) * a (j + (x+1))) =
        (∑ x ∈ Finset.range k, (k.choose (x+1) : ℝ) * a (j + (x+1))) +
        (∑ x ∈ Finset.range k, (k.choose x : ℝ) * a (j + (x+1))) := by
      rw [← Finset.sum_add_distrib]
      apply Finset.sum_congr rfl
      intro x _
      ring
    rw [hcomb]
    ring

/-- Identity: n * C(n-1, l) = (l+1) * C(n, l+1). -/
lemma choose_div_nat (n l : ℕ) (hn : n ≥ 1) :
    n * ((n-1).choose l) = (l+1) * (n.choose (l+1)) := by
  obtain ⟨m, rfl⟩ : ∃ m, n = m + 1 := ⟨n - 1, by omega⟩
  simp only [Nat.add_sub_cancel]
  exact Nat.add_one_mul_choose_eq m l

end Putnam2003B2Aux

theorem putnam_2003_b2 (n : ℕ) (hn : n ≥ 1) :
    ((fun (b : ℕ → ℝ) (i : ℕ) => (b i + b (i + 1)) / 2)^[n-1]
      (fun i => 1 / ((i : ℝ) + 1))) 0 < 2 / n := by
  show (Putnam2003B2Aux.avg^[n-1] (fun i => 1 / ((i : ℝ) + 1))) 0 < 2 / n
  rw [Putnam2003B2Aux.avg_iter]
  have hn1 : n - 1 + 1 = n := by omega
  rw [hn1]
  have hnpos : (0 : ℝ) < n := by exact_mod_cast (by omega : 0 < n)
  have hnne : (n : ℝ) ≠ 0 := ne_of_gt hnpos
  have h2n1pos : (0 : ℝ) < 2^(n-1) := by positivity
  -- Replace each term: C(n-1, l) * 1/(0+l+1) = C(n,l+1) / n
  have keyterm : ∀ l ∈ Finset.range n,
      ((n-1).choose l : ℝ) * (1 / (((0 : ℕ) + l : ℕ) : ℝ) + 1) =
      ((n-1).choose l : ℝ) * (1 / ((l : ℝ) + 1)) := by
    intro l _
    push_cast
    ring_nf
  -- Sum after substitution: (1/n) * ∑ C(n, l+1) = (2^n - 1)/n
  have hkey : ∑ l ∈ Finset.range n, ((n-1).choose l : ℝ) * (1 / (((0 + l : ℕ) : ℝ) + 1)) =
      ((2:ℝ)^n - 1) / n := by
    have step1 : ∀ l ∈ Finset.range n,
        ((n-1).choose l : ℝ) * (1 / (((0 + l : ℕ) : ℝ) + 1)) =
        (n.choose (l+1) : ℝ) / n := by
      intro l _
      have hl1 : ((l : ℝ) + 1) ≠ 0 := by positivity
      have heq : (n : ℕ) * ((n-1).choose l) = (l+1) * (n.choose (l+1)) :=
        Putnam2003B2Aux.choose_div_nat n l hn
      have heq' : (n : ℝ) * ((n-1).choose l : ℝ) = ((l : ℝ) + 1) * ((n.choose (l+1)) : ℝ) := by
        exact_mod_cast heq
      have hcast : ((0 + l : ℕ) : ℝ) + 1 = (l : ℝ) + 1 := by push_cast; ring
      rw [hcast]
      field_simp
      linarith
    rw [Finset.sum_congr rfl step1]
    -- ∑ C(n,l+1) / n
    rw [← Finset.sum_div]
    -- ∑ C(n,l+1) = 2^n - 1
    have hsum : ∑ l ∈ Finset.range n, (n.choose (l+1) : ℝ) = (2:ℝ)^n - 1 := by
      have htotal : (∑ m ∈ Finset.range (n+1), (n.choose m : ℝ)) = (2:ℝ)^n := by
        have := Nat.sum_range_choose n
        have hcast : ((∑ m ∈ Finset.range (n+1), n.choose m : ℕ) : ℝ) = ((2^n : ℕ) : ℝ) := by
          exact_mod_cast this
        push_cast at hcast
        exact hcast
      have hsplit : ∑ m ∈ Finset.range (n+1), (n.choose m : ℝ) =
          (n.choose 0 : ℝ) + ∑ l ∈ Finset.range n, (n.choose (l+1) : ℝ) := by
        rw [Finset.sum_range_succ' (fun m => (n.choose m : ℝ)) n]
        simp [add_comm]
      rw [hsplit] at htotal
      simp at htotal
      linarith
    rw [hsum]
  rw [hkey]
  -- Goal: 1/2^(n-1) * ((2^n - 1)/n) < 2/n
  -- Equivalent: (2^n - 1) / (n * 2^(n-1)) < 2/n
  -- Equivalent: 2^n - 1 < 2 * 2^(n-1) = 2^n.
  have h2n : (2:ℝ)^n = 2 * 2^(n-1) := by
    have : (n - 1) + 1 = n := by omega
    rw [← this, pow_succ]; ring
  rw [h2n]
  rw [div_lt_div_iff (by positivity) hnpos]
  have : (1/(2:ℝ)^(n-1)) * ((2 * 2^(n-1) - 1) / n) * n = 2 * 2^(n-1) / 2^(n-1) - 1 / 2^(n-1) := by
    field_simp
  rw [this]
  rw [show (2 * (2:ℝ)^(n-1)) / 2^(n-1) = 2 from by
    field_simp]
  -- Goal: 2 - 1/2^(n-1) < 2 * (2^(n-1) * n)... no wait
  -- We did div_lt_div_iff so goal is: (1/2^(n-1)) * ((2*2^(n-1) - 1)/n) * n < 2 * 2^(n-1)
  -- After my rewrites: 2 - 1/2^(n-1) < 2 * 2^(n-1)
  -- For n=1: 2^(n-1)=1, so 2-1 = 1 < 2. ✓
  -- For n≥2: 2 - 1/2^(n-1) < 2 ≤ 2 * 2^(n-1).  ✓
  have h1 : 2 - 1 / (2:ℝ)^(n-1) ≤ 2 := by
    have : (0 : ℝ) ≤ 1 / 2^(n-1) := by positivity
    linarith
  have h2 : (2 : ℝ) ≤ 2 * 2^(n-1) := by
    have : (1 : ℝ) ≤ 2^(n-1) := one_le_pow₀ (by norm_num : (1:ℝ) ≤ 2)
    nlinarith
  have hpos : (0 : ℝ) < 1 / (2:ℝ)^(n-1) := by positivity
  linarith
