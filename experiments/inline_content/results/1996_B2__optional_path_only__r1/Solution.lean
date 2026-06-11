import Mathlib

open Finset

noncomputable def g (k : ℕ) : ℝ :=
  ((2 * (k : ℝ) + 1) / Real.exp 1) ^ ((2 * (k : ℝ) + 1) / 2)

lemma gpos (k : ℕ) : 0 < g k := by
  unfold g
  apply Real.rpow_pos_of_pos
  positivity

lemma logg (k : ℕ) :
    Real.log (g k) = (2 * (k : ℝ) + 1) / 2 * (Real.log (2 * (k : ℝ) + 1) - 1) := by
  unfold g
  rw [Real.log_rpow (by positivity), Real.log_div (by positivity) (by positivity),
      Real.log_exp]

-- g (k+1) ≤ (2k+3) * g k
lemma lower (k : ℕ) : g (k + 1) ≤ (2 * (k : ℝ) + 3) * g k := by
  have hk1 : (0:ℝ) < 2 * (k : ℝ) + 1 := by positivity
  have hk3 : (0:ℝ) < 2 * (k : ℝ) + 3 := by positivity
  have hbound : Real.log (2 * (k : ℝ) + 3) - Real.log (2 * (k : ℝ) + 1) ≤ 2 / (2 * (k : ℝ) + 1) := by
    have := Real.log_le_sub_one_of_pos (x := (2 * (k : ℝ) + 3) / (2 * (k : ℝ) + 1)) (by positivity)
    rw [Real.log_div (by positivity) (by positivity)] at this
    have hd : (2 * (k : ℝ) + 3) / (2 * (k : ℝ) + 1) - 1 = 2 / (2 * (k : ℝ) + 1) := by
      field_simp; ring
    rw [hd] at this
    linarith
  have key : Real.log (g (k + 1)) ≤ Real.log ((2 * (k : ℝ) + 3) * g k) := by
    rw [Real.log_mul (by positivity) (ne_of_gt (gpos k)), logg, logg]
    push_cast
    nlinarith [hbound, hk1, hk3]
  have h1 := gpos (k + 1)
  have h2 : 0 < (2 * (k : ℝ) + 3) * g k := by positivity
  exact (Real.log_le_log_iff h1 h2).mp key

-- (2k+1) * g k ≤ g (k+1)
lemma upper (k : ℕ) : (2 * (k : ℝ) + 1) * g k ≤ g (k + 1) := by
  have hk1 : (0:ℝ) < 2 * (k : ℝ) + 1 := by positivity
  have hk3 : (0:ℝ) < 2 * (k : ℝ) + 3 := by positivity
  have hbound : Real.log (2 * (k : ℝ) + 1) - Real.log (2 * (k : ℝ) + 3) ≤ -2 / (2 * (k : ℝ) + 3) := by
    have := Real.log_le_sub_one_of_pos (x := (2 * (k : ℝ) + 1) / (2 * (k : ℝ) + 3)) (by positivity)
    rw [Real.log_div (by positivity) (by positivity)] at this
    have hd : (2 * (k : ℝ) + 1) / (2 * (k : ℝ) + 3) - 1 = -2 / (2 * (k : ℝ) + 3) := by
      field_simp; ring
    rw [hd] at this
    linarith
  have key : Real.log ((2 * (k : ℝ) + 1) * g k) ≤ Real.log (g (k + 1)) := by
    rw [Real.log_mul (by positivity) (ne_of_gt (gpos k)), logg, logg]
    push_cast
    nlinarith [hbound, hk1, hk3]
  have h1 : 0 < (2 * (k : ℝ) + 1) * g k := by positivity
  have h2 := gpos (k + 1)
  exact (Real.log_le_log_iff h1 h2).mp key

lemma main (m : ℕ) :
    g m < (∏ i ∈ Finset.range (m + 1), (2 * (i : ℝ) + 1)) ∧
      (∏ i ∈ Finset.range (m + 1), (2 * (i : ℝ) + 1)) < g (m + 1) := by
  induction m with
  | zero =>
    rw [Finset.prod_range_one]
    constructor
    · -- g 0 < 1
      have h00 : g 0 = (1 / Real.exp 1) ^ ((1:ℝ) / 2) := by
        unfold g; norm_num
      rw [h00]
      have he : (1:ℝ) < Real.exp 1 := by
        have := Real.add_one_le_exp (1:ℝ); linarith
      have : ((1:ℝ) / Real.exp 1) ^ ((1:ℝ) / 2) < 1 := by
        apply Real.rpow_lt_one (by positivity) _ (by norm_num)
        rw [div_lt_one (Real.exp_pos 1)]; linarith
      simpa using this
    · -- 1 < g 1
      have h01 : g 1 = (3 / Real.exp 1) ^ ((3:ℝ) / 2) := by
        unfold g; norm_num
      rw [h01]
      have hlt : Real.exp 1 < 3 := by
        have := Real.exp_one_lt_d9; linarith
      have h3e : (1:ℝ) < 3 / Real.exp 1 := by
        rw [lt_div_iff (Real.exp_pos 1)]; linarith
      have : (1:ℝ) < (3 / Real.exp 1) ^ ((3:ℝ) / 2) := by
        apply Real.one_lt_rpow_iff_of_pos (by positivity) |>.mpr
        left; exact ⟨h3e, by norm_num⟩
      simpa using this
  | succ m ih =>
    obtain ⟨ihl, ihr⟩ := ih
    have hk3 : (0:ℝ) < 2 * (m : ℝ) + 3 := by positivity
    rw [Finset.prod_range_succ]
    constructor
    · -- g (m+1) < (∏ range (m+1)) * (2*(m+1)+1)
      have hfac : (2 * ((m + 1 : ℕ) : ℝ) + 1) = 2 * (m : ℝ) + 3 := by push_cast; ring
      rw [hfac]
      calc g (m + 1) ≤ (2 * (m : ℝ) + 3) * g m := lower m
        _ < (2 * (m : ℝ) + 3) * (∏ i ∈ Finset.range (m + 1), (2 * (i : ℝ) + 1)) := by
              apply mul_lt_mul_of_pos_left ihl hk3
        _ = (∏ i ∈ Finset.range (m + 1), (2 * (i : ℝ) + 1)) * (2 * ((m + 1 : ℕ) : ℝ) + 1) := by
              rw [hfac]; ring
    · -- (∏ range (m+1)) * (2*(m+1)+1) < g (m+2)
      have hfac : (2 * ((m + 1 : ℕ) : ℝ) + 1) = 2 * (m : ℝ) + 3 := by push_cast; ring
      rw [hfac]
      have hup : (2 * ((m + 1 : ℕ) : ℝ) + 1) * g (m + 1) ≤ g (m + 2) := upper (m + 1)
      rw [hfac] at hup
      calc (∏ i ∈ Finset.range (m + 1), (2 * (i : ℝ) + 1)) * (2 * (m : ℝ) + 3)
            = (2 * (m : ℝ) + 3) * (∏ i ∈ Finset.range (m + 1), (2 * (i : ℝ) + 1)) := by ring
        _ < (2 * (m : ℝ) + 3) * g (m + 1) := by apply mul_lt_mul_of_pos_left ihr hk3
        _ ≤ g (m + 2) := hup

theorem putnam_1996_b2 (n : ℕ) (hn : 0 < n) :
    ((2 * (n : ℝ) - 1) / Real.exp 1) ^ ((2 * (n : ℝ) - 1) / 2) <
        ∏ i ∈ Finset.range n, (2 * (i : ℝ) + 1) ∧
      (∏ i ∈ Finset.range n, (2 * (i : ℝ) + 1)) <
        ((2 * (n : ℝ) + 1) / Real.exp 1) ^ ((2 * (n : ℝ) + 1) / 2) := by
  obtain ⟨m, rfl⟩ : ∃ m, n = m + 1 := ⟨n - 1, by omega⟩
  obtain ⟨hl, hr⟩ := main m
  constructor
  · have heq : ((2 * ((m + 1 : ℕ) : ℝ) - 1) / Real.exp 1) ^ ((2 * ((m + 1 : ℕ) : ℝ) - 1) / 2) = g m := by
      unfold g; congr 1 <;> push_cast <;> ring
    rw [heq]; exact hl
  · have heq : ((2 * ((m + 1 : ℕ) : ℝ) + 1) / Real.exp 1) ^ ((2 * ((m + 1 : ℕ) : ℝ) + 1) / 2) = g (m + 1) := by
      unfold g; congr 1 <;> push_cast <;> ring
    rw [heq]; exact hr
