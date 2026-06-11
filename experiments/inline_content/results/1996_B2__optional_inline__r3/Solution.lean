import Mathlib

open Finset

noncomputable def fb (x : ℝ) : ℝ := x / 2 * (Real.log x - 1)

lemma fb_step_low (x : ℝ) (hx : 0 < x) : fb (x + 2) ≤ fb x + Real.log (x + 2) := by
  have hx2 : (0:ℝ) < x + 2 := by linarith
  have hdiv : Real.log (x + 2) - Real.log x = Real.log ((x + 2) / x) := by
    rw [Real.log_div (ne_of_gt hx2) (ne_of_gt hx)]
  have hpos : (0:ℝ) < (x + 2) / x := by positivity
  have hle : Real.log ((x + 2) / x) ≤ (x + 2) / x - 1 := Real.log_le_sub_one_of_pos hpos
  have h2x : x * (Real.log (x + 2) - Real.log x) ≤ 2 := by
    rw [hdiv]
    have hmul := mul_le_mul_of_nonneg_left hle (le_of_lt hx)
    have heq : x * ((x + 2) / x - 1) = 2 := by field_simp; ring
    linarith [hmul, heq]
  simp only [fb]
  nlinarith [h2x, hx]

lemma fb_step_upp (x : ℝ) (hx : 0 < x) : fb x + Real.log x ≤ fb (x + 2) := by
  have hx2 : (0:ℝ) < x + 2 := by linarith
  have hdiv : Real.log (x + 2) - Real.log x = Real.log ((x + 2) / x) := by
    rw [Real.log_div (ne_of_gt hx2) (ne_of_gt hx)]
  have hge : 1 - ((x + 2) / x)⁻¹ ≤ Real.log ((x + 2) / x) := by
    have h := Real.log_le_sub_one_of_pos (show (0:ℝ) < ((x + 2) / x)⁻¹ by positivity)
    rw [Real.log_inv] at h
    linarith
  have h2x : 2 ≤ (x + 2) * (Real.log (x + 2) - Real.log x) := by
    rw [hdiv]
    have hinv : ((x + 2) / x)⁻¹ = x / (x + 2) := by rw [inv_div]
    rw [hinv] at hge
    have hmul := mul_le_mul_of_nonneg_left hge (le_of_lt hx2)
    have heq : (x + 2) * (1 - x / (x + 2)) = 2 := by field_simp; ring
    linarith [hmul, heq]
  simp only [fb]
  nlinarith [h2x, hx]

lemma key_low : ∀ n : ℕ, fb (2 * (n:ℝ) + 1) <
    ∑ k ∈ Finset.range (n + 1), Real.log (2 * (k:ℝ) + 1) := by
  intro n
  induction n with
  | zero =>
    simp only [Nat.cast_zero, mul_zero, zero_add, Finset.sum_range_one, fb, Real.log_one]
    norm_num
  | succ n ih =>
    have hx : (0:ℝ) < 2 * (n:ℝ) + 1 := by positivity
    have hstep := fb_step_low (2 * (n:ℝ) + 1) hx
    have key : fb (2 * ((n:ℝ) + 1) + 1) ≤ fb (2 * (n:ℝ) + 1) + Real.log (2 * ((n:ℝ) + 1) + 1) := by
      have e : 2 * ((n:ℝ) + 1) + 1 = 2 * (n:ℝ) + 1 + 2 := by ring
      rw [e]; exact hstep
    rw [Finset.sum_range_succ]
    push_cast
    linarith [ih, key]

lemma key_upp : ∀ n : ℕ, ∑ k ∈ Finset.range (n + 1), Real.log (2 * (k:ℝ) + 1) <
    fb (2 * (n:ℝ) + 3) := by
  intro n
  induction n with
  | zero =>
    have hlog3 : (1:ℝ) < Real.log 3 := by
      have h1 : Real.exp 1 < 3 := by
        have h := Real.exp_one_lt_d9
        linarith
      calc (1:ℝ) = Real.log (Real.exp 1) := (Real.log_exp 1).symm
        _ < Real.log 3 := Real.log_lt_log (Real.exp_pos 1) h1
    simp only [Nat.cast_zero, mul_zero, zero_add, Finset.sum_range_one, fb, Real.log_one]
    nlinarith [hlog3]
  | succ n ih =>
    have hx : (0:ℝ) < 2 * (n:ℝ) + 3 := by positivity
    have hstep := fb_step_upp (2 * (n:ℝ) + 3) hx
    have key : fb (2 * (n:ℝ) + 3) + Real.log (2 * ((n:ℝ) + 1) + 1) ≤ fb (2 * ((n:ℝ) + 1) + 3) := by
      have e1 : 2 * ((n:ℝ) + 1) + 1 = 2 * (n:ℝ) + 3 := by ring
      have e2 : 2 * ((n:ℝ) + 1) + 3 = 2 * (n:ℝ) + 3 + 2 := by ring
      rw [e1, e2]; exact hstep
    rw [Finset.sum_range_succ]
    push_cast
    linarith [ih, key]

theorem putnam_1996_b2 (n : ℕ) (hn : 0 < n) :
    ((2 * (n:ℝ) - 1) / Real.exp 1) ^ ((2 * (n:ℝ) - 1) / 2) <
      ∏ k ∈ Finset.range n, (2 * (k:ℝ) + 1) ∧
    (∏ k ∈ Finset.range n, (2 * (k:ℝ) + 1)) <
      ((2 * (n:ℝ) + 1) / Real.exp 1) ^ ((2 * (n:ℝ) + 1) / 2) := by
  obtain ⟨m, rfl⟩ : ∃ m, n = m + 1 := ⟨n - 1, by omega⟩
  set Q := ∏ k ∈ Finset.range (m + 1), (2 * (k:ℝ) + 1) with hQdef
  have hQpos : 0 < Q := by
    rw [hQdef]; exact Finset.prod_pos (fun k _ => by positivity)
  have hlogQ : Real.log Q = ∑ k ∈ Finset.range (m + 1), Real.log (2 * (k:ℝ) + 1) := by
    rw [hQdef, Real.log_prod]
    intro k _
    exact (by positivity : (0:ℝ) < 2 * (k:ℝ) + 1).ne'
  push_cast
  rw [show (2 * ((m:ℝ) + 1) - 1) = 2 * (m:ℝ) + 1 by ring,
      show (2 * ((m:ℝ) + 1) + 1) = 2 * (m:ℝ) + 3 by ring]
  refine ⟨?_, ?_⟩
  · have hbase : (0:ℝ) < (2 * (m:ℝ) + 1) / Real.exp 1 := by positivity
    have hLpos : (0:ℝ) < ((2 * (m:ℝ) + 1) / Real.exp 1) ^ ((2 * (m:ℝ) + 1) / 2) :=
      Real.rpow_pos_of_pos hbase _
    have hlogL : Real.log (((2 * (m:ℝ) + 1) / Real.exp 1) ^ ((2 * (m:ℝ) + 1) / 2))
        = fb (2 * (m:ℝ) + 1) := by
      rw [Real.log_rpow hbase, Real.log_div (ne_of_gt (by positivity)) (Real.exp_ne_zero 1),
        Real.log_exp]
      simp only [fb]
    rw [← Real.exp_log hLpos, ← Real.exp_log hQpos]
    apply Real.exp_lt_exp.mpr
    rw [hlogL, hlogQ]
    exact key_low m
  · have hbase : (0:ℝ) < (2 * (m:ℝ) + 3) / Real.exp 1 := by positivity
    have hUpos : (0:ℝ) < ((2 * (m:ℝ) + 3) / Real.exp 1) ^ ((2 * (m:ℝ) + 3) / 2) :=
      Real.rpow_pos_of_pos hbase _
    have hlogU : Real.log (((2 * (m:ℝ) + 3) / Real.exp 1) ^ ((2 * (m:ℝ) + 3) / 2))
        = fb (2 * (m:ℝ) + 3) := by
      rw [Real.log_rpow hbase, Real.log_div (ne_of_gt (by positivity)) (Real.exp_ne_zero 1),
        Real.log_exp]
      simp only [fb]
    rw [← Real.exp_log hQpos, ← Real.exp_log hUpos]
    apply Real.exp_lt_exp.mpr
    rw [hlogU, hlogQ]
    exact key_upp m
