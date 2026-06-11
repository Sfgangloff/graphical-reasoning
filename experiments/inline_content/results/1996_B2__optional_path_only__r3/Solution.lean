import Mathlib

open Finset

/-- Step inequality (upper side): `((m+2)/e)^((m+2)/2) ≤ (m+2) * (m/e)^(m/2)`. -/
private lemma stepL (m : ℝ) (hm : 1 ≤ m) :
    ((m + 2) / Real.exp 1) ^ ((m + 2) / 2) ≤ (m + 2) * (m / Real.exp 1) ^ (m / 2) := by
  have hm0 : (0 : ℝ) < m := lt_of_lt_of_le one_pos hm
  have he : (0 : ℝ) < Real.exp 1 := Real.exp_pos 1
  have hm2 : (0 : ℝ) < m + 2 := by linarith
  have hme : (0 : ℝ) < m / Real.exp 1 := div_pos hm0 he
  have hm2e : (0 : ℝ) < (m + 2) / Real.exp 1 := div_pos hm2 he
  rw [Real.rpow_def_of_pos hm2e, Real.rpow_def_of_pos hme,
      Real.log_div (ne_of_gt hm2) (ne_of_gt he),
      Real.log_div (ne_of_gt hm0) (ne_of_gt he)]
  simp only [Real.log_exp]
  conv_rhs => rw [← Real.exp_log hm2]
  rw [← Real.exp_add, Real.exp_le_exp]
  -- scalar goal
  have hkey2 : (Real.log (m + 2) - Real.log m) * m ≤ 2 := by
    have h := Real.log_le_sub_one_of_pos (show (0 : ℝ) < (m + 2) / m from div_pos hm2 hm0)
    rw [Real.log_div (ne_of_gt hm2) (ne_of_gt hm0)] at h
    have he2 : (m + 2) / m * m = m + 2 := by field_simp
    nlinarith [mul_le_mul_of_nonneg_right h (le_of_lt hm0), he2]
  nlinarith [hkey2]

/-- Step inequality (lower side): `m * (m/e)^(m/2) ≤ ((m+2)/e)^((m+2)/2)`. -/
private lemma stepR (m : ℝ) (hm : 1 ≤ m) :
    m * (m / Real.exp 1) ^ (m / 2) ≤ ((m + 2) / Real.exp 1) ^ ((m + 2) / 2) := by
  have hm0 : (0 : ℝ) < m := lt_of_lt_of_le one_pos hm
  have he : (0 : ℝ) < Real.exp 1 := Real.exp_pos 1
  have hm2 : (0 : ℝ) < m + 2 := by linarith
  have hme : (0 : ℝ) < m / Real.exp 1 := div_pos hm0 he
  have hm2e : (0 : ℝ) < (m + 2) / Real.exp 1 := div_pos hm2 he
  rw [Real.rpow_def_of_pos hme, Real.rpow_def_of_pos hm2e,
      Real.log_div (ne_of_gt hm0) (ne_of_gt he),
      Real.log_div (ne_of_gt hm2) (ne_of_gt he)]
  simp only [Real.log_exp]
  nth_rewrite 1 [← Real.exp_log hm0]
  rw [← Real.exp_add, Real.exp_le_exp]
  -- scalar goal
  have hkey : 2 ≤ (Real.log (m + 2) - Real.log m) * (m + 2) := by
    have h := Real.log_le_sub_one_of_pos (show (0 : ℝ) < m / (m + 2) from div_pos hm0 hm2)
    rw [Real.log_div (ne_of_gt hm0) (ne_of_gt hm2)] at h
    have he2 : m / (m + 2) * (m + 2) = m := by field_simp
    nlinarith [mul_le_mul_of_nonneg_right h (le_of_lt hm2), he2]
  nlinarith [hkey]

private lemma leftLem (n : ℕ) (hn : 1 ≤ n) :
    ((2 * (n : ℝ) - 1) / Real.exp 1) ^ ((2 * (n : ℝ) - 1) / 2) <
      ∏ k ∈ Finset.range n, (2 * (k : ℝ) + 1) := by
  induction n, hn using Nat.le_induction with
  | base =>
    have hp : (∏ k ∈ Finset.range 1, (2 * (k : ℝ) + 1)) = 1 := by simp
    rw [hp]
    have hb : (2 * ((1 : ℕ) : ℝ) - 1) = 1 := by push_cast; ring
    rw [hb]
    apply Real.rpow_lt_one (by positivity) ?_ (by norm_num)
    rw [div_lt_one (Real.exp_pos 1)]
    linarith [Real.exp_one_gt_d9]
  | succ n hn ih =>
    rw [Finset.prod_range_succ]
    push_cast
    have hnr : (1 : ℝ) ≤ (n : ℝ) := by exact_mod_cast hn
    have hm : (1 : ℝ) ≤ 2 * (n : ℝ) - 1 := by linarith
    have hs := stepL (2 * (n : ℝ) - 1) hm
    have hcoef : 2 * (n : ℝ) - 1 + 2 = 2 * (n : ℝ) + 1 := by ring
    rw [hcoef] at hs
    calc ((2 * ((n : ℝ) + 1) - 1) / Real.exp 1) ^ ((2 * ((n : ℝ) + 1) - 1) / 2)
          = ((2 * (n : ℝ) + 1) / Real.exp 1) ^ ((2 * (n : ℝ) + 1) / 2) := by
            congr 2 <;> ring
      _ ≤ (2 * (n : ℝ) + 1) * ((2 * (n : ℝ) - 1) / Real.exp 1) ^ ((2 * (n : ℝ) - 1) / 2) := hs
      _ < (2 * (n : ℝ) + 1) * (∏ k ∈ Finset.range n, (2 * (k : ℝ) + 1)) := by
            apply mul_lt_mul_of_pos_left ih; positivity
      _ = (∏ k ∈ Finset.range n, (2 * (k : ℝ) + 1)) * (2 * (n : ℝ) + 1) := by ring

private lemma rightLem (n : ℕ) (hn : 1 ≤ n) :
    (∏ k ∈ Finset.range n, (2 * (k : ℝ) + 1)) <
      ((2 * (n : ℝ) + 1) / Real.exp 1) ^ ((2 * (n : ℝ) + 1) / 2) := by
  induction n, hn using Nat.le_induction with
  | base =>
    have hp : (∏ k ∈ Finset.range 1, (2 * (k : ℝ) + 1)) = 1 := by simp
    rw [hp]
    have hb : (2 * ((1 : ℕ) : ℝ) + 1) = 3 := by push_cast; ring
    rw [hb]
    conv_lhs => rw [show (1 : ℝ) = (1 : ℝ) ^ ((3 : ℝ) / 2) from (Real.one_rpow _).symm]
    apply Real.rpow_lt_rpow (by norm_num) ?_ (by norm_num)
    rw [lt_div_iff₀ (Real.exp_pos 1), one_mul]
    linarith [Real.exp_one_lt_d9]
  | succ n hn ih =>
    rw [Finset.prod_range_succ]
    push_cast
    have hnr : (1 : ℝ) ≤ (n : ℝ) := by exact_mod_cast hn
    have hm : (1 : ℝ) ≤ 2 * (n : ℝ) + 1 := by linarith
    have hs := stepR (2 * (n : ℝ) + 1) hm
    have hcoef : 2 * (n : ℝ) + 1 + 2 = 2 * ((n : ℝ) + 1) + 1 := by ring
    rw [hcoef] at hs
    calc (∏ k ∈ Finset.range n, (2 * (k : ℝ) + 1)) * (2 * (n : ℝ) + 1)
          < ((2 * (n : ℝ) + 1) / Real.exp 1) ^ ((2 * (n : ℝ) + 1) / 2) * (2 * (n : ℝ) + 1) := by
            apply mul_lt_mul_of_pos_right ih; positivity
      _ = (2 * (n : ℝ) + 1) * ((2 * (n : ℝ) + 1) / Real.exp 1) ^ ((2 * (n : ℝ) + 1) / 2) := by ring
      _ ≤ ((2 * ((n : ℝ) + 1) + 1) / Real.exp 1) ^ ((2 * ((n : ℝ) + 1) + 1) / 2) := hs

theorem putnam_1996_b2 (n : ℕ) (hn : 0 < n) :
    ((2 * (n : ℝ) - 1) / Real.exp 1) ^ ((2 * (n : ℝ) - 1) / 2) <
      ∏ k ∈ Finset.range n, (2 * (k : ℝ) + 1) ∧
    (∏ k ∈ Finset.range n, (2 * (k : ℝ) + 1)) <
      ((2 * (n : ℝ) + 1) / Real.exp 1) ^ ((2 * (n : ℝ) + 1) / 2) :=
  ⟨leftLem n hn, rightLem n hn⟩
