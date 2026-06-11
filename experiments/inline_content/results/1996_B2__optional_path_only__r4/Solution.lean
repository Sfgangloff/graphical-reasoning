import Mathlib

open Finset

theorem putnam_1996_b2 (n : ℕ) (hn : 0 < n) :
    ((2 * (n : ℝ) - 1) / Real.exp 1) ^ (((2 * (n : ℝ) - 1)) / 2)
        < ∏ i ∈ Finset.Icc 1 n, (2 * (i : ℝ) - 1) ∧
    (∏ i ∈ Finset.Icc 1 n, (2 * (i : ℝ) - 1))
        < ((2 * (n : ℝ) + 1) / Real.exp 1) ^ (((2 * (n : ℝ) + 1)) / 2) := by
  -- F a = (a/e)^(a/2) written as an exponential
  have key : ∀ a : ℝ, 0 < a →
      (a / Real.exp 1) ^ (a / 2) = Real.exp ((Real.log a - 1) * (a / 2)) := by
    intro a ha
    rw [Real.rpow_def_of_pos (by positivity), Real.log_div (ne_of_gt ha) (Real.exp_ne_zero 1),
      Real.log_exp]
  -- step for the right inequality
  have stepR : ∀ m : ℝ, 0 < m →
      m * Real.exp ((Real.log m - 1) * (m / 2))
        ≤ Real.exp ((Real.log (m + 2) - 1) * ((m + 2) / 2)) := by
    intro m hm
    have hm2 : (0:ℝ) < m + 2 := by linarith
    have hrw : m * Real.exp ((Real.log m - 1) * (m / 2))
        = Real.exp (Real.log m + (Real.log m - 1) * (m / 2)) := by
      rw [Real.exp_add, Real.exp_log hm]
    rw [hrw, Real.exp_le_exp]
    have hb : Real.log (m / (m + 2)) ≤ m / (m + 2) - 1 :=
      Real.log_le_sub_one_of_pos (by positivity)
    rw [Real.log_div (ne_of_gt hm) (ne_of_gt hm2)] at hb
    have hb2 : (Real.log m - Real.log (m + 2)) * (m + 2) ≤ -2 := by
      have h3 := mul_le_mul_of_nonneg_right hb (le_of_lt hm2)
      have h4 : (m / (m + 2) - 1) * (m + 2) = -2 := by field_simp; ring
      rw [h4] at h3; exact h3
    nlinarith [hb2]
  -- step for the left inequality
  have stepL : ∀ m : ℝ, 0 < m →
      Real.exp ((Real.log (m + 2) - 1) * ((m + 2) / 2))
        ≤ (m + 2) * Real.exp ((Real.log m - 1) * (m / 2)) := by
    intro m hm
    have hm2 : (0:ℝ) < m + 2 := by linarith
    have hrw : (m + 2) * Real.exp ((Real.log m - 1) * (m / 2))
        = Real.exp (Real.log (m + 2) + (Real.log m - 1) * (m / 2)) := by
      rw [Real.exp_add, Real.exp_log hm2]
    rw [hrw, Real.exp_le_exp]
    have hb : Real.log ((m + 2) / m) ≤ (m + 2) / m - 1 :=
      Real.log_le_sub_one_of_pos (by positivity)
    rw [Real.log_div (ne_of_gt hm2) (ne_of_gt hm)] at hb
    have hb2 : (Real.log (m + 2) - Real.log m) * m ≤ 2 := by
      have h3 := mul_le_mul_of_nonneg_right hb (le_of_lt hm)
      have h4 : ((m + 2) / m - 1) * m = 2 := by field_simp; ring
      rw [h4] at h3; exact h3
    nlinarith [hb2]
  -- product recurrence
  have Prec : ∀ k : ℕ, (∏ i ∈ Finset.Icc 1 (k + 1), (2 * (i : ℝ) - 1))
      = (∏ i ∈ Finset.Icc 1 k, (2 * (i : ℝ) - 1)) * (2 * (k : ℝ) + 1) := by
    intro k
    rw [Finset.prod_Icc_succ_top (by omega : 1 ≤ k + 1)]
    push_cast; ring
  -- base product value
  have hp1 : (∏ i ∈ Finset.Icc (1:ℕ) 1, (2 * (i : ℝ) - 1)) = 1 := by norm_num
  -- right inequality
  have right : ∀ N : ℕ, 1 ≤ N →
      (∏ i ∈ Finset.Icc 1 N, (2 * (i : ℝ) - 1))
        < Real.exp ((Real.log (2 * (N : ℝ) + 1) - 1) * ((2 * (N : ℝ) + 1) / 2)) := by
    intro N hN
    induction N, hN using Nat.le_induction with
    | base =>
      rw [hp1, show (2 * ((1 : ℕ) : ℝ) + 1) = 3 by norm_num]
      rw [Real.one_lt_exp_iff]
      have he3 : Real.exp 1 < 3 := by have := Real.exp_one_lt_d9; norm_num at this ⊢; linarith
      have hlog3 : 1 < Real.log 3 := by
        rw [show (1 : ℝ) = Real.log (Real.exp 1) from (Real.log_exp 1).symm]
        exact Real.log_lt_log (Real.exp_pos 1) he3
      nlinarith [hlog3]
    | succ k hk ih =>
      rw [Prec k]
      have hk1 : (0:ℝ) < 2 * (k : ℝ) + 1 := by positivity
      have step := stepR (2 * (k : ℝ) + 1) hk1
      have harg : (2 * (k : ℝ) + 1) + 2 = 2 * ((k : ℝ) + 1) + 1 := by ring
      rw [harg] at step
      have hmul : (∏ i ∈ Finset.Icc 1 k, (2 * (i : ℝ) - 1)) * (2 * (k : ℝ) + 1)
          < Real.exp ((Real.log (2 * (k : ℝ) + 1) - 1) * ((2 * (k : ℝ) + 1) / 2)) * (2 * (k : ℝ) + 1) :=
        mul_lt_mul_of_pos_right ih hk1
      rw [mul_comm (Real.exp ((Real.log (2 * (k : ℝ) + 1) - 1) * ((2 * (k : ℝ) + 1) / 2)))
        (2 * (k : ℝ) + 1)] at hmul
      have hlt := lt_of_lt_of_le hmul step
      push_cast
      exact hlt
  -- left inequality
  have left : ∀ N : ℕ, 1 ≤ N →
      Real.exp ((Real.log (2 * (N : ℝ) - 1) - 1) * ((2 * (N : ℝ) - 1) / 2))
        < (∏ i ∈ Finset.Icc 1 N, (2 * (i : ℝ) - 1)) := by
    intro N hN
    induction N, hN using Nat.le_induction with
    | base =>
      rw [hp1, show (2 * ((1 : ℕ) : ℝ) - 1) = 1 by norm_num, Real.log_one]
      rw [Real.exp_lt_one_iff]
      norm_num
    | succ k hk ih =>
      rw [Prec k]
      have hk1 : (0:ℝ) < 2 * (k : ℝ) + 1 := by positivity
      have hkm : (0:ℝ) < 2 * (k : ℝ) - 1 := by
        have : (1 : ℝ) ≤ (k : ℝ) := by exact_mod_cast hk
        linarith
      have step := stepL (2 * (k : ℝ) - 1) hkm
      have harg : (2 * (k : ℝ) - 1) + 2 = 2 * (k : ℝ) + 1 := by ring
      rw [harg] at step
      have hmul : (2 * (k : ℝ) + 1) * Real.exp ((Real.log (2 * (k : ℝ) - 1) - 1) * ((2 * (k : ℝ) - 1) / 2))
          < (2 * (k : ℝ) + 1) * (∏ i ∈ Finset.Icc 1 k, (2 * (i : ℝ) - 1)) :=
        mul_lt_mul_of_pos_left ih hk1
      have hlt := lt_of_le_of_lt step hmul
      push_cast
      rw [show (2 * ((k : ℝ) + 1) - 1) = 2 * (k : ℝ) + 1 from by ring,
        mul_comm (∏ i ∈ Finset.Icc 1 k, (2 * (i : ℝ) - 1)) (2 * (k : ℝ) + 1)]
      exact hlt
  have hpos1 : (0:ℝ) < 2 * (n : ℝ) - 1 := by
    have : (1 : ℝ) ≤ (n : ℝ) := by exact_mod_cast hn
    linarith
  have hpos2 : (0:ℝ) < 2 * (n : ℝ) + 1 := by positivity
  refine ⟨?_, ?_⟩
  · rw [key (2 * (n : ℝ) - 1) hpos1]
    exact left n hn
  · rw [key (2 * (n : ℝ) + 1) hpos2]
    exact right n hn
