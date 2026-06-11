import Mathlib

open Finset

theorem putnam_1996_b2 (n : ℕ) (hn : 0 < n) :
    ((2 * (n : ℝ) - 1) / Real.exp 1) ^ (((2 * (n : ℝ) - 1)) / 2) <
      ∏ i ∈ Finset.Icc 1 n, (2 * (i : ℝ) - 1) ∧
    (∏ i ∈ Finset.Icc 1 n, (2 * (i : ℝ) - 1)) <
      ((2 * (n : ℝ) + 1) / Real.exp 1) ^ (((2 * (n : ℝ) + 1)) / 2) := by
  -- convert rpow expression to exp form
  have hE : ∀ m : ℝ, 0 < m →
      (m / Real.exp 1) ^ (m / 2) = Real.exp ((Real.log m - 1) * (m / 2)) := by
    intro m hm
    rw [Real.rpow_def_of_pos (by positivity)]
    congr 1
    rw [Real.log_div (ne_of_gt hm) (Real.exp_ne_zero 1), Real.log_exp]
  -- positivity of the product
  have hPpos : ∀ k : ℕ, 0 < ∏ i ∈ Finset.Icc 1 k, (2 * (i : ℝ) - 1) := by
    intro k
    apply Finset.prod_pos
    intro i hi
    simp only [Finset.mem_Icc] at hi
    have : (1 : ℝ) ≤ (i : ℝ) := by exact_mod_cast hi.1
    linarith
  -- step lemma 1 (upper): m * E m ≤ E (m+2)
  have step1 : ∀ m : ℝ, 0 < m →
      m * Real.exp ((Real.log m - 1) * (m / 2)) ≤
        Real.exp ((Real.log (m + 2) - 1) * ((m + 2) / 2)) := by
    intro m hm
    have hm2 : (0 : ℝ) < m + 2 := by linarith
    have hrw : m * Real.exp ((Real.log m - 1) * (m / 2)) =
        Real.exp (Real.log m + (Real.log m - 1) * (m / 2)) := by
      rw [Real.exp_add, Real.exp_log hm]
    rw [hrw]
    apply Real.exp_le_exp.mpr
    have h := Real.log_le_sub_one_of_pos (show (0:ℝ) < m / (m + 2) by positivity)
    rw [Real.log_div (ne_of_gt hm) (ne_of_gt hm2)] at h
    have hmul : (Real.log m - Real.log (m + 2)) * (m + 2) ≤ (m / (m + 2) - 1) * (m + 2) :=
      mul_le_mul_of_nonneg_right h hm2.le
    have hsimp : (m / (m + 2) - 1) * (m + 2) = -2 := by field_simp; ring
    rw [hsimp] at hmul
    nlinarith [hmul, hm2]
  -- step lemma 2 (lower): E (m+2) ≤ (m+2) * E m
  have step2 : ∀ m : ℝ, 0 < m →
      Real.exp ((Real.log (m + 2) - 1) * ((m + 2) / 2)) ≤
        (m + 2) * Real.exp ((Real.log m - 1) * (m / 2)) := by
    intro m hm
    have hm2 : (0 : ℝ) < m + 2 := by linarith
    have hrw : (m + 2) * Real.exp ((Real.log m - 1) * (m / 2)) =
        Real.exp (Real.log (m + 2) + (Real.log m - 1) * (m / 2)) := by
      rw [Real.exp_add, Real.exp_log hm2]
    rw [hrw]
    apply Real.exp_le_exp.mpr
    have h := Real.log_le_sub_one_of_pos (show (0:ℝ) < (m + 2) / m by positivity)
    rw [Real.log_div (ne_of_gt hm2) (ne_of_gt hm)] at h
    have hmul : (Real.log (m + 2) - Real.log m) * m ≤ ((m + 2) / m - 1) * m :=
      mul_le_mul_of_nonneg_right h hm.le
    have hsimp : ((m + 2) / m - 1) * m = 2 := by field_simp; ring
    rw [hsimp] at hmul
    nlinarith [hmul, hm]
  -- main induction
  have main : ∀ k : ℕ, 1 ≤ k →
      Real.exp ((Real.log (2 * (k : ℝ) - 1) - 1) * ((2 * (k : ℝ) - 1) / 2)) <
        (∏ i ∈ Finset.Icc 1 k, (2 * (i : ℝ) - 1)) ∧
      (∏ i ∈ Finset.Icc 1 k, (2 * (i : ℝ) - 1)) <
        Real.exp ((Real.log (2 * (k : ℝ) + 1) - 1) * ((2 * (k : ℝ) + 1) / 2)) := by
    intro k hk
    induction k, hk using Nat.le_induction with
    | base =>
      simp only [Nat.cast_one, Finset.Icc_self, Finset.prod_singleton]
      norm_num
      -- remaining goal: 1 < Real.log 3
      rw [show (1:ℝ) = Real.log (Real.exp 1) from (Real.log_exp 1).symm]
      apply Real.log_lt_log (Real.exp_pos 1)
      have := Real.exp_one_lt_d9
      linarith
    | succ n hn ih =>
      have hn1 : (1 : ℝ) ≤ (n : ℝ) := by exact_mod_cast hn
      have hmpos : (0 : ℝ) < 2 * (n : ℝ) - 1 := by linarith
      -- equalities relating index n+1 to n
      have e1 : 2 * ((n : ℝ) + 1) - 1 = (2 * (n : ℝ) - 1) + 2 := by ring
      have e2 : 2 * ((n : ℝ) + 1) + 1 = (2 * (n : ℝ) - 1) + 4 := by ring
      have e0 : 2 * (n : ℝ) + 1 = (2 * (n : ℝ) - 1) + 2 := by ring
      have hprod : (∏ i ∈ Finset.Icc 1 (n + 1), (2 * (i : ℝ) - 1)) =
          (∏ i ∈ Finset.Icc 1 n, (2 * (i : ℝ) - 1)) * ((2 * (n : ℝ) - 1) + 2) := by
        rw [Finset.prod_Icc_succ_top (by omega : 1 ≤ n + 1)]
        push_cast; ring
      obtain ⟨ihlo, ihhi⟩ := ih
      -- rewrite ih's upper arg using e0
      rw [e0] at ihhi
      simp only [Nat.cast_add, Nat.cast_one]
      rw [e1, e2, hprod]
      set m : ℝ := 2 * (n : ℝ) - 1 with hm_def
      have hposP : 0 < ∏ i ∈ Finset.Icc 1 n, (2 * (i : ℝ) - 1) := hPpos n
      have hm2pos : (0 : ℝ) < m + 2 := by linarith
      constructor
      · -- lower: exp(U(n)) < P n * (m+2)
        calc Real.exp ((Real.log (m + 2) - 1) * ((m + 2) / 2))
            ≤ (m + 2) * Real.exp ((Real.log m - 1) * (m / 2)) := step2 m hmpos
          _ < (m + 2) * (∏ i ∈ Finset.Icc 1 n, (2 * (i : ℝ) - 1)) := by
              apply mul_lt_mul_of_pos_left ihlo hm2pos
          _ = (∏ i ∈ Finset.Icc 1 n, (2 * (i : ℝ) - 1)) * (m + 2) := by ring
      · -- upper: P n * (m+2) < exp(U(n+1)) = exp((log(m+4)-1)*((m+4)/2))
        have hstep := step1 (m + 2) hm2pos
        rw [show (m + 2) + 2 = m + 4 by ring] at hstep
        calc (∏ i ∈ Finset.Icc 1 n, (2 * (i : ℝ) - 1)) * (m + 2)
            < Real.exp ((Real.log (m + 2) - 1) * ((m + 2) / 2)) * (m + 2) := by
              apply mul_lt_mul_of_pos_right ihhi hm2pos
          _ = (m + 2) * Real.exp ((Real.log (m + 2) - 1) * ((m + 2) / 2)) := by ring
          _ ≤ Real.exp ((Real.log (m + 4) - 1) * ((m + 4) / 2)) := hstep
  -- assemble
  obtain ⟨hlo, hhi⟩ := main n hn
  rw [hE (2 * (n : ℝ) - 1) (by
        have : (1:ℝ) ≤ (n:ℝ) := by exact_mod_cast hn
        linarith),
      hE (2 * (n : ℝ) + 1) (by positivity)]
  exact ⟨hlo, hhi⟩
