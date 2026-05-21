import Mathlib

open Real

private lemma prodpos (m : ℕ) :
    0 < ∏ i ∈ Finset.range m, (2 * (i : ℝ) + 1) := by
  apply Finset.prod_pos
  intro i _
  positivity

/-- Log-sum form of the bound, proved by induction starting at `n = 1`. -/
private lemma logbound : ∀ n : ℕ, 1 ≤ n →
    (2 * (n : ℝ) - 1) / 2 * (Real.log (2 * (n : ℝ) - 1) - 1)
        < Real.log (∏ i ∈ Finset.range n, (2 * (i : ℝ) + 1))
    ∧ Real.log (∏ i ∈ Finset.range n, (2 * (i : ℝ) + 1))
        < (2 * (n : ℝ) + 1) / 2 * (Real.log (2 * (n : ℝ) + 1) - 1) := by
  intro n hn
  induction n, hn using Nat.le_induction with
  | base =>
      have hprod : (∏ i ∈ Finset.range 1, (2 * (i : ℝ) + 1)) = 1 := by
        norm_num [Finset.prod_range_one]
      have h3 : (1 : ℝ) < Real.log 3 := by
        have hlt : Real.log (Real.exp 1) < Real.log 3 := by
          apply Real.log_lt_log (by positivity)
          have := Real.exp_one_lt_d9
          linarith
        simpa using hlt
      constructor
      · rw [hprod, Real.log_one]
        norm_num [Real.log_one]
      · rw [hprod, Real.log_one]
        norm_num
        nlinarith [h3]
  | succ k hk ih =>
      have hk1 : (1 : ℝ) ≤ (k : ℝ) := by exact_mod_cast hk
      have hkpos2m1 : (0 : ℝ) < 2 * (k : ℝ) - 1 := by linarith
      have hkpos2p1 : (0 : ℝ) < 2 * (k : ℝ) + 1 := by linarith
      have hkpos2p3 : (0 : ℝ) < 2 * (k : ℝ) + 3 := by linarith
      have hne2m1 : (2 * (k : ℝ) - 1) ≠ 0 := ne_of_gt hkpos2m1
      have hne2p1 : (2 * (k : ℝ) + 1) ≠ 0 := ne_of_gt hkpos2p1
      have hne2p3 : (2 * (k : ℝ) + 3) ≠ 0 := ne_of_gt hkpos2p3
      have hprodsucc :
          Real.log (∏ i ∈ Finset.range (k + 1), (2 * (i : ℝ) + 1))
            = Real.log (∏ i ∈ Finset.range k, (2 * (i : ℝ) + 1))
              + Real.log (2 * (k : ℝ) + 1) := by
        rw [Finset.prod_range_succ,
          Real.log_mul (ne_of_gt (prodpos k)) (ne_of_gt hkpos2p1)]
      obtain ⟨ihlo, ihhi⟩ := ih
      -- (I): (2k-1) * (log(2k+1) - log(2k-1)) ≤ 2
      have hmulI : (2 * (k : ℝ) - 1)
          * (Real.log (2 * (k : ℝ) + 1) - Real.log (2 * (k : ℝ) - 1)) ≤ 2 := by
        have hx : (0 : ℝ) < (2 * (k : ℝ) + 1) / (2 * (k : ℝ) - 1) := by positivity
        have h0 := Real.log_le_sub_one_of_pos hx
        rw [Real.log_div hne2p1 hne2m1] at h0
        have hprod : (2 * (k : ℝ) - 1)
            * ((2 * (k : ℝ) + 1) / (2 * (k : ℝ) - 1) - 1) = 2 := by
          field_simp
          ring
        calc (2 * (k : ℝ) - 1)
              * (Real.log (2 * (k : ℝ) + 1) - Real.log (2 * (k : ℝ) - 1))
            ≤ (2 * (k : ℝ) - 1)
              * ((2 * (k : ℝ) + 1) / (2 * (k : ℝ) - 1) - 1) :=
              mul_le_mul_of_nonneg_left h0 (le_of_lt hkpos2m1)
          _ = 2 := hprod
      -- (II): (2k+3) * (log(2k+1) - log(2k+3)) ≤ -2
      have hmulII : (2 * (k : ℝ) + 3)
          * (Real.log (2 * (k : ℝ) + 1) - Real.log (2 * (k : ℝ) + 3)) ≤ -2 := by
        have hx : (0 : ℝ) < (2 * (k : ℝ) + 1) / (2 * (k : ℝ) + 3) := by positivity
        have h0 := Real.log_le_sub_one_of_pos hx
        rw [Real.log_div hne2p1 hne2p3] at h0
        have hprod : (2 * (k : ℝ) + 3)
            * ((2 * (k : ℝ) + 1) / (2 * (k : ℝ) + 3) - 1) = -2 := by
          field_simp
          ring
        calc (2 * (k : ℝ) + 3)
              * (Real.log (2 * (k : ℝ) + 1) - Real.log (2 * (k : ℝ) + 3))
            ≤ (2 * (k : ℝ) + 3)
              * ((2 * (k : ℝ) + 1) / (2 * (k : ℝ) + 3) - 1) :=
              mul_le_mul_of_nonneg_left h0 (le_of_lt hkpos2p3)
          _ = -2 := hprod
      constructor
      · -- lower bound at k+1
        push_cast
        rw [show (2 * ((k : ℝ) + 1) - 1) = 2 * (k : ℝ) + 1 from by ring]
        rw [hprodsucc]
        nlinarith [ihlo, hmulI]
      · -- upper bound at k+1
        push_cast
        rw [show (2 * ((k : ℝ) + 1) + 1) = 2 * (k : ℝ) + 3 from by ring]
        rw [hprodsucc]
        nlinarith [ihhi, hmulII]

theorem putnam_1996_b2
    (n : ℕ)
    (npos : 0 < n) :
    ((2 * (n : ℝ) - 1) / Real.exp 1) ^ ((2 * (n : ℝ) - 1) / 2)
      < ∏ i ∈ Finset.range n, (2 * (i : ℝ) + 1)
    ∧ ∏ i ∈ Finset.range n, (2 * (i : ℝ) + 1)
      < ((2 * (n : ℝ) + 1) / Real.exp 1) ^ ((2 * (n : ℝ) + 1) / 2) := by
  have hn : 1 ≤ n := npos
  have hnr : (1 : ℝ) ≤ (n : ℝ) := by exact_mod_cast hn
  have h2m1 : (0 : ℝ) < 2 * (n : ℝ) - 1 := by linarith
  have h2p1 : (0 : ℝ) < 2 * (n : ℝ) + 1 := by linarith
  have hP : 0 < ∏ i ∈ Finset.range n, (2 * (i : ℝ) + 1) := prodpos n
  obtain ⟨lo, hi⟩ := logbound n hn
  constructor
  · -- lower bound
    have hbase : (0 : ℝ) < (2 * (n : ℝ) - 1) / Real.exp 1 := by positivity
    have hLpos : 0 < ((2 * (n : ℝ) - 1) / Real.exp 1) ^ ((2 * (n : ℝ) - 1) / 2) := by
      positivity
    have hlog :
        Real.log (((2 * (n : ℝ) - 1) / Real.exp 1) ^ ((2 * (n : ℝ) - 1) / 2))
          = (2 * (n : ℝ) - 1) / 2 * (Real.log (2 * (n : ℝ) - 1) - 1) := by
      rw [Real.log_rpow hbase, Real.log_div (ne_of_gt h2m1) (by positivity),
        Real.log_exp]
    have key : Real.log (((2 * (n : ℝ) - 1) / Real.exp 1) ^ ((2 * (n : ℝ) - 1) / 2))
        < Real.log (∏ i ∈ Finset.range n, (2 * (i : ℝ) + 1)) := by
      rw [hlog]; exact lo
    calc ((2 * (n : ℝ) - 1) / Real.exp 1) ^ ((2 * (n : ℝ) - 1) / 2)
        = Real.exp (Real.log (((2 * (n : ℝ) - 1) / Real.exp 1) ^ ((2 * (n : ℝ) - 1) / 2))) :=
          (Real.exp_log hLpos).symm
      _ < Real.exp (Real.log (∏ i ∈ Finset.range n, (2 * (i : ℝ) + 1))) :=
          Real.exp_lt_exp.mpr key
      _ = ∏ i ∈ Finset.range n, (2 * (i : ℝ) + 1) := Real.exp_log hP
  · -- upper bound
    have hbase : (0 : ℝ) < (2 * (n : ℝ) + 1) / Real.exp 1 := by positivity
    have hUpos : 0 < ((2 * (n : ℝ) + 1) / Real.exp 1) ^ ((2 * (n : ℝ) + 1) / 2) := by
      positivity
    have hlog :
        Real.log (((2 * (n : ℝ) + 1) / Real.exp 1) ^ ((2 * (n : ℝ) + 1) / 2))
          = (2 * (n : ℝ) + 1) / 2 * (Real.log (2 * (n : ℝ) + 1) - 1) := by
      rw [Real.log_rpow hbase, Real.log_div (ne_of_gt h2p1) (by positivity),
        Real.log_exp]
    have key : Real.log (∏ i ∈ Finset.range n, (2 * (i : ℝ) + 1))
        < Real.log (((2 * (n : ℝ) + 1) / Real.exp 1) ^ ((2 * (n : ℝ) + 1) / 2)) := by
      rw [hlog]; exact hi
    calc ∏ i ∈ Finset.range n, (2 * (i : ℝ) + 1)
        = Real.exp (Real.log (∏ i ∈ Finset.range n, (2 * (i : ℝ) + 1))) :=
          (Real.exp_log hP).symm
      _ < Real.exp (Real.log (((2 * (n : ℝ) + 1) / Real.exp 1) ^ ((2 * (n : ℝ) + 1) / 2))) :=
          Real.exp_lt_exp.mpr key
      _ = ((2 * (n : ℝ) + 1) / Real.exp 1) ^ ((2 * (n : ℝ) + 1) / 2) := Real.exp_log hUpos
