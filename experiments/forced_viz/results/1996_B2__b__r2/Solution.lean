import Mathlib

open Finset

theorem putnam_1996_b2 (n : ℕ) (hn : 0 < n) :
    ((2 * (n : ℝ) - 1) / Real.exp 1) ^ ((2 * (n : ℝ) - 1) / 2) <
      ∏ i ∈ Finset.range n, (2 * (i : ℝ) + 1) ∧
    (∏ i ∈ Finset.range n, (2 * (i : ℝ) + 1)) <
      ((2 * (n : ℝ) + 1) / Real.exp 1) ^ ((2 * (n : ℝ) + 1) / 2) := by
  -- positivity ⇒ comparison of logs ⇒ comparison
  have lt_of_log_lt : ∀ a b : ℝ, 0 < a → 0 < b → Real.log a < Real.log b → a < b := by
    intro a b ha hb h
    have := Real.exp_lt_exp.mpr h
    rwa [Real.exp_log ha, Real.exp_log hb] at this
  -- main inequality on logs, by induction starting at 1
  have key : ∀ m : ℕ, 1 ≤ m →
      ((2 * (m : ℝ) - 1) / 2 * (Real.log (2 * (m : ℝ) - 1) - 1) <
          Real.log (∏ i ∈ Finset.range m, (2 * (i : ℝ) + 1))) ∧
      (Real.log (∏ i ∈ Finset.range m, (2 * (i : ℝ) + 1)) <
          (2 * (m : ℝ) + 1) / 2 * (Real.log (2 * (m : ℝ) + 1) - 1)) := by
    intro m hm
    induction m, hm using Nat.le_induction with
    | base =>
        have hp : Real.log (∏ i ∈ Finset.range 1, (2 * (i : ℝ) + 1)) = 0 := by
          simp [Finset.prod_range_one, Real.log_one]
        refine ⟨?_, ?_⟩
        · rw [hp]
          simp only [Nat.cast_one]
          norm_num [Real.log_one]
        · rw [hp]
          have h3 : Real.exp 1 < 3 := by linarith [Real.exp_one_lt_d9]
          have hlog3 : (1 : ℝ) < Real.log 3 := by
            have := Real.log_lt_log (Real.exp_pos 1) h3
            rwa [Real.log_exp] at this
          simp only [Nat.cast_one]
          nlinarith [hlog3]
    | succ k hk ih =>
        have hkk : (1 : ℝ) ≤ (k : ℝ) := by exact_mod_cast hk
        have hd1 : (0 : ℝ) < 2 * (k : ℝ) - 1 := by linarith
        have hd2 : (0 : ℝ) < 2 * (k : ℝ) + 1 := by linarith
        have hd3 : (0 : ℝ) < 2 * (k : ℝ) + 3 := by linarith
        -- log( (2k+1)/(2k-1) ) ≤ (2k+1)/(2k-1) - 1
        have hlow := Real.log_le_sub_one_of_pos
          (show (0 : ℝ) < (2 * (k : ℝ) + 1) / (2 * (k : ℝ) - 1) by positivity)
        rw [Real.log_div hd2.ne' hd1.ne'] at hlow
        have hab : (2 * (k : ℝ) - 1) * (Real.log (2 * (k : ℝ) + 1) - Real.log (2 * (k : ℝ) - 1)) ≤ 2 := by
          have e : (2 * (k : ℝ) - 1) * ((2 * (k : ℝ) + 1) / (2 * (k : ℝ) - 1) - 1) = 2 := by
            field_simp
          have hmul := mul_le_mul_of_nonneg_left hlow hd1.le
          linarith [hmul, e.le, e.ge]
        -- log( (2k+1)/(2k+3) ) ≤ (2k+1)/(2k+3) - 1
        have hhig := Real.log_le_sub_one_of_pos
          (show (0 : ℝ) < (2 * (k : ℝ) + 1) / (2 * (k : ℝ) + 3) by positivity)
        rw [Real.log_div hd2.ne' hd3.ne'] at hhig
        have hcb : (2 : ℝ) ≤ (2 * (k : ℝ) + 3) * (Real.log (2 * (k : ℝ) + 3) - Real.log (2 * (k : ℝ) + 1)) := by
          have e : (2 * (k : ℝ) + 3) * ((2 * (k : ℝ) + 1) / (2 * (k : ℝ) + 3) - 1) = -2 := by
            field_simp
          have hmul := mul_le_mul_of_nonneg_left hhig hd3.le
          linarith [hmul, e.le, e.ge]
        push_cast
        rw [show (2 * ((k : ℝ) + 1) - 1 : ℝ) = 2 * (k : ℝ) + 1 from by ring,
            show (2 * ((k : ℝ) + 1) + 1 : ℝ) = 2 * (k : ℝ) + 3 from by ring,
            Finset.prod_range_succ,
            Real.log_mul (by positivity) (by positivity)]
        push_cast at ih ⊢
        refine ⟨?_, ?_⟩
        · nlinarith [ih.1, hab]
        · nlinarith [ih.2, hcb]
  -- conclude
  have hn1 : 1 ≤ n := hn
  obtain ⟨kl, ku⟩ := key n hn1
  have hnR : (1 : ℝ) ≤ (n : ℝ) := by exact_mod_cast hn1
  have ht1 : (0 : ℝ) < 2 * (n : ℝ) - 1 := by linarith
  have ht3 : (0 : ℝ) < 2 * (n : ℝ) + 1 := by linarith
  have hQpos : (0 : ℝ) < ∏ i ∈ Finset.range n, (2 * (i : ℝ) + 1) :=
    Finset.prod_pos (fun i _ => by positivity)
  have hbase1 : (0 : ℝ) < (2 * (n : ℝ) - 1) / Real.exp 1 := by positivity
  have hbase3 : (0 : ℝ) < (2 * (n : ℝ) + 1) / Real.exp 1 := by positivity
  have hLHSpos : (0 : ℝ) < ((2 * (n : ℝ) - 1) / Real.exp 1) ^ ((2 * (n : ℝ) - 1) / 2) :=
    Real.rpow_pos_of_pos hbase1 _
  have hRHSpos : (0 : ℝ) < ((2 * (n : ℝ) + 1) / Real.exp 1) ^ ((2 * (n : ℝ) + 1) / 2) :=
    Real.rpow_pos_of_pos hbase3 _
  have logL : Real.log (((2 * (n : ℝ) - 1) / Real.exp 1) ^ ((2 * (n : ℝ) - 1) / 2))
      = (2 * (n : ℝ) - 1) / 2 * (Real.log (2 * (n : ℝ) - 1) - 1) := by
    rw [Real.log_rpow hbase1, Real.log_div ht1.ne' (Real.exp_pos 1).ne', Real.log_exp]
  have logR : Real.log (((2 * (n : ℝ) + 1) / Real.exp 1) ^ ((2 * (n : ℝ) + 1) / 2))
      = (2 * (n : ℝ) + 1) / 2 * (Real.log (2 * (n : ℝ) + 1) - 1) := by
    rw [Real.log_rpow hbase3, Real.log_div ht3.ne' (Real.exp_pos 1).ne', Real.log_exp]
  refine ⟨?_, ?_⟩
  · apply lt_of_log_lt _ _ hLHSpos hQpos
    rw [logL]; exact kl
  · apply lt_of_log_lt _ _ hQpos hRHSpos
    rw [logR]; exact ku
