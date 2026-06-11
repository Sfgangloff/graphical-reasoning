import Mathlib

open scoped BigOperators

namespace Putnam1996B2

lemma lt_of_log_lt {A B : ℝ} (hA : 0 < A) (hB : 0 < B)
    (h : Real.log A < Real.log B) : A < B := by
  have := Real.exp_lt_exp.mpr h
  rwa [Real.exp_log hA, Real.exp_log hB] at this

/-- For `y > 0`, `y ≠ 1`: `log y < y - 1`. -/
lemma log_lt (y : ℝ) (hy : 0 < y) (hy1 : y ≠ 1) : Real.log y < y - 1 := by
  have h1 : y < Real.exp (y - 1) := by
    have := Real.add_one_lt_exp (x := y - 1) (sub_ne_zero.mpr hy1)
    linarith
  have h2 := Real.log_lt_log hy h1
  rwa [Real.log_exp] at h2

/-- For `y > 0`, `y ≠ 1`: `1 - y⁻¹ < log y`. -/
lemma log_gt (y : ℝ) (hy : 0 < y) (hy1 : y ≠ 1) : 1 - y⁻¹ < Real.log y := by
  have hinv : (0:ℝ) < y⁻¹ := by positivity
  have hinv1 : y⁻¹ ≠ 1 := by simpa using hy1
  have h := log_lt y⁻¹ hinv hinv1
  rw [Real.log_inv] at h
  linarith

/-- `b - a < b * (log b - log a)` for `0 < a < b`. -/
lemma logA (a b : ℝ) (ha : 0 < a) (hb : 0 < b) (hab : a < b) :
    b - a < b * (Real.log b - Real.log a) := by
  have hba : (1:ℝ) < b / a := (one_lt_div ha).mpr hab
  have hne : b / a ≠ 1 := hba.ne'
  have hpos : (0:ℝ) < b / a := by positivity
  have h := log_gt (b / a) hpos hne
  rw [Real.log_div (ne_of_gt hb) (ne_of_gt ha), inv_div] at h
  have h2 := mul_lt_mul_of_pos_right h hb
  have h3 : (1 - a / b) * b = b - a := by field_simp
  rw [h3] at h2
  nlinarith [h2]

/-- `a * (log b - log a) < b - a` for `0 < a < b`. -/
lemma logB (a b : ℝ) (ha : 0 < a) (hb : 0 < b) (hab : a < b) :
    a * (Real.log b - Real.log a) < b - a := by
  have hba : (1:ℝ) < b / a := (one_lt_div ha).mpr hab
  have hne : b / a ≠ 1 := hba.ne'
  have hpos : (0:ℝ) < b / a := by positivity
  have h := log_lt (b / a) hpos hne
  rw [Real.log_div (ne_of_gt hb) (ne_of_gt ha)] at h
  have h2 := mul_lt_mul_of_pos_right h ha
  have h3 : (b / a - 1) * a = b - a := by field_simp
  rw [h3] at h2
  nlinarith [h2]

noncomputable def g (x : ℝ) : ℝ := x / 2 * (Real.log x - 1)

lemma L1 (m : ℝ) (hm : 1 ≤ m) : Real.log m < g (m + 2) - g m := by
  have hm0 : 0 < m := by linarith
  have hm2 : 0 < m + 2 := by linarith
  have key := logA m (m + 2) hm0 hm2 (by linarith)
  unfold g
  nlinarith [key]

lemma L2 (m : ℝ) (hm : 1 ≤ m) : g (m + 2) - g m < Real.log (m + 2) := by
  have hm0 : 0 < m := by linarith
  have hm2 : 0 < m + 2 := by linarith
  have key := logB m (m + 2) hm0 hm2 (by linarith)
  unfold g
  nlinarith [key]

noncomputable def S (n : ℕ) : ℝ := ∑ i ∈ Finset.range n, Real.log (2 * (i : ℝ) + 1)

lemma lower : ∀ n : ℕ, 1 ≤ n → g (2 * (n : ℝ) - 1) < S n := by
  intro n hn
  induction n, hn using Nat.le_induction with
  | base =>
    have hS : S 1 = 0 := by unfold S; rw [Finset.sum_range_one]; norm_num [Real.log_one]
    rw [hS]
    norm_num [g, Real.log_one]
  | succ k hk ih =>
    have h1k : (1:ℝ) ≤ (k : ℝ) := by exact_mod_cast hk
    have hm : (1:ℝ) ≤ 2 * (k : ℝ) - 1 := by linarith
    have hSs : S (k + 1) = S k + Real.log (2 * (k : ℝ) + 1) := by
      unfold S; rw [Finset.sum_range_succ]
    have hL2 := L2 (2 * (k : ℝ) - 1) hm
    have e2 : (2 * (k : ℝ) - 1) + 2 = 2 * (k : ℝ) + 1 := by ring
    rw [e2] at hL2
    have e : 2 * ((k + 1 : ℕ) : ℝ) - 1 = 2 * (k : ℝ) + 1 := by push_cast; ring
    rw [hSs, e]
    linarith [hL2, ih]

lemma upper : ∀ n : ℕ, 1 ≤ n → S n < g (2 * (n : ℝ) + 1) := by
  intro n hn
  induction n, hn using Nat.le_induction with
  | base =>
    have hS : S 1 = 0 := by unfold S; rw [Finset.sum_range_one]; norm_num [Real.log_one]
    rw [hS]
    have hlog3 : 1 < Real.log 3 := by
      have hexp : Real.exp 1 < 3 := by linarith [Real.exp_one_lt_d9]
      have h := Real.log_lt_log (Real.exp_pos 1) hexp
      rwa [Real.log_exp] at h
    have he : (2 * ((1:ℕ) : ℝ) + 1) = 3 := by norm_num
    rw [he]; unfold g
    nlinarith [hlog3]
  | succ k hk ih =>
    have h1k : (1:ℝ) ≤ (k : ℝ) := by exact_mod_cast hk
    have hm : (1:ℝ) ≤ 2 * (k : ℝ) + 1 := by linarith
    have hSs : S (k + 1) = S k + Real.log (2 * (k : ℝ) + 1) := by
      unfold S; rw [Finset.sum_range_succ]
    have hL1 := L1 (2 * (k : ℝ) + 1) hm
    have e : 2 * ((k + 1 : ℕ) : ℝ) + 1 = (2 * (k : ℝ) + 1) + 2 := by push_cast; ring
    rw [hSs, e]
    linarith [hL1, ih]

end Putnam1996B2

open Putnam1996B2 in
theorem putnam_1996_b2 (n : ℕ) (hn : 0 < n) :
    ((2 * (n : ℝ) - 1) / Real.exp 1) ^ ((2 * (n : ℝ) - 1) / 2) <
      (∏ i ∈ Finset.range n, (2 * (i : ℝ) + 1)) ∧
    (∏ i ∈ Finset.range n, (2 * (i : ℝ) + 1)) <
      ((2 * (n : ℝ) + 1) / Real.exp 1) ^ ((2 * (n : ℝ) + 1) / 2) := by
  have hn1 : 1 ≤ n := hn
  have hnr : (1:ℝ) ≤ (n : ℝ) := by exact_mod_cast hn1
  have h2n1 : (0:ℝ) < 2 * (n : ℝ) - 1 := by linarith
  have h2n3 : (0:ℝ) < 2 * (n : ℝ) + 1 := by linarith
  have hPpos : (0:ℝ) < ∏ i ∈ Finset.range n, (2 * (i : ℝ) + 1) := by
    apply Finset.prod_pos; intro i _; positivity
  have hlogP : Real.log (∏ i ∈ Finset.range n, (2 * (i : ℝ) + 1)) = S n := by
    unfold S
    rw [Real.log_prod]
    intro i _
    exact ne_of_gt (by positivity)
  have hbaseL : (0:ℝ) < (2 * (n : ℝ) - 1) / Real.exp 1 := div_pos h2n1 (Real.exp_pos 1)
  have hApos : (0:ℝ) < ((2 * (n : ℝ) - 1) / Real.exp 1) ^ ((2 * (n : ℝ) - 1) / 2) :=
    Real.rpow_pos_of_pos hbaseL _
  have hlogAeq : Real.log (((2 * (n : ℝ) - 1) / Real.exp 1) ^ ((2 * (n : ℝ) - 1) / 2))
      = g (2 * (n : ℝ) - 1) := by
    rw [Real.log_rpow hbaseL, Real.log_div (ne_of_gt h2n1) (ne_of_gt (Real.exp_pos 1)),
      Real.log_exp]
    unfold g; ring
  have hbaseR : (0:ℝ) < (2 * (n : ℝ) + 1) / Real.exp 1 := div_pos h2n3 (Real.exp_pos 1)
  have hBpos : (0:ℝ) < ((2 * (n : ℝ) + 1) / Real.exp 1) ^ ((2 * (n : ℝ) + 1) / 2) :=
    Real.rpow_pos_of_pos hbaseR _
  have hlogBeq : Real.log (((2 * (n : ℝ) + 1) / Real.exp 1) ^ ((2 * (n : ℝ) + 1) / 2))
      = g (2 * (n : ℝ) + 1) := by
    rw [Real.log_rpow hbaseR, Real.log_div (ne_of_gt h2n3) (ne_of_gt (Real.exp_pos 1)),
      Real.log_exp]
    unfold g; ring
  constructor
  · apply lt_of_log_lt hApos hPpos
    rw [hlogAeq, hlogP]
    exact lower n hn1
  · apply lt_of_log_lt hPpos hBpos
    rw [hlogP, hlogBeq]
    exact upper n hn1
