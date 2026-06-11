import Mathlib

open Real Finset

/-- `g(a+2) ≤ g(a) + log(a+2)` where `g(m) = m/2*(log m - 1)`. -/
private lemma log_step_le (a : ℝ) (ha : 0 < a) :
    (a + 2) / 2 * (Real.log (a + 2) - 1) ≤ a / 2 * (Real.log a - 1) + Real.log (a + 2) := by
  have hpos2 : (0:ℝ) < a + 2 := by linarith
  have key : a * (Real.log (a + 2) - Real.log a) ≤ 2 := by
    have h := Real.log_le_sub_one_of_pos (show (0:ℝ) < (a + 2) / a by positivity)
    rw [Real.log_div (ne_of_gt hpos2) (ne_of_gt ha)] at h
    have hk : a * ((a + 2) / a - 1) = 2 := by field_simp; ring
    nlinarith [mul_le_mul_of_nonneg_left h ha.le, hk]
  nlinarith [key, ha]

/-- `g(a) + log a ≤ g(a+2)` where `g(m) = m/2*(log m - 1)`. -/
private lemma log_step_ge (a : ℝ) (ha : 0 < a) :
    a / 2 * (Real.log a - 1) + Real.log a ≤ (a + 2) / 2 * (Real.log (a + 2) - 1) := by
  have hpos2 : (0:ℝ) < a + 2 := by linarith
  have key : 2 ≤ (a + 2) * (Real.log (a + 2) - Real.log a) := by
    have h := Real.log_le_sub_one_of_pos (show (0:ℝ) < a / (a + 2) by positivity)
    rw [Real.log_div (ne_of_gt ha) (ne_of_gt hpos2)] at h
    have hk : (a + 2) * (a / (a + 2) - 1) = -2 := by field_simp; ring
    nlinarith [mul_le_mul_of_nonneg_left h hpos2.le, hk]
  nlinarith [key, hpos2]

private lemma sum_log_bounds (n : ℕ) (hn : 1 ≤ n) :
    (2 * (n:ℝ) - 1) / 2 * (Real.log (2 * (n:ℝ) - 1) - 1)
        < ∑ k ∈ Finset.Icc 1 n, Real.log (2 * (k:ℝ) - 1)
    ∧ (∑ k ∈ Finset.Icc 1 n, Real.log (2 * (k:ℝ) - 1))
        < (2 * (n:ℝ) + 1) / 2 * (Real.log (2 * (n:ℝ) + 1) - 1) := by
  induction n, hn using Nat.le_induction with
  | base =>
    have he : Real.exp 1 < 3 := by nlinarith [Real.exp_one_lt_d9]
    have hlog3 : (1:ℝ) < Real.log 3 := by
      have := Real.log_lt_log (Real.exp_pos 1) he; rwa [Real.log_exp] at this
    rw [Finset.Icc_self, Finset.sum_singleton, Nat.cast_one]
    simp only [show (2 * (1:ℝ) - 1) = 1 by norm_num, show (2 * (1:ℝ) + 1) = 3 by norm_num,
      Real.log_one]
    refine ⟨by norm_num, by nlinarith [hlog3]⟩
  | succ m hm ih =>
    obtain ⟨ih1, ih2⟩ := ih
    have hm1 : (1:ℝ) ≤ m := by exact_mod_cast hm
    have hpa : (0:ℝ) < 2 * (m:ℝ) - 1 := by linarith
    have hpb : (0:ℝ) < 2 * (m:ℝ) + 1 := by linarith
    have sle := log_step_le (2 * (m:ℝ) - 1) hpa
    have sge := log_step_ge (2 * (m:ℝ) + 1) hpb
    rw [Finset.sum_Icc_succ_top (by omega : 1 ≤ m + 1)]
    push_cast
    ring_nf
    ring_nf at ih1 ih2 sle sge
    constructor
    · linarith [ih1, sle]
    · linarith [ih2, sge]

theorem putnam_1996_b2 (n : ℕ) (hn : 0 < n) :
    ((2 * (n : ℝ) - 1) / Real.exp 1) ^ ((2 * (n : ℝ) - 1) / 2) <
        ∏ k ∈ Finset.Icc 1 n, (2 * (k : ℝ) - 1) ∧
    (∏ k ∈ Finset.Icc 1 n, (2 * (k : ℝ) - 1)) <
        ((2 * (n : ℝ) + 1) / Real.exp 1) ^ ((2 * (n : ℝ) + 1) / 2) := by
  have hn1 : 1 ≤ n := hn
  obtain ⟨hlow, hupp⟩ := sum_log_bounds n hn1
  have hfac : ∀ k ∈ Finset.Icc 1 n, (0:ℝ) < 2 * (k:ℝ) - 1 := by
    intro k hk
    simp only [Finset.mem_Icc] at hk
    have : (1:ℝ) ≤ k := by exact_mod_cast hk.1
    linarith
  have hP : (0:ℝ) < ∏ k ∈ Finset.Icc 1 n, (2 * (k:ℝ) - 1) := Finset.prod_pos hfac
  have hlogP : Real.log (∏ k ∈ Finset.Icc 1 n, (2 * (k:ℝ) - 1))
      = ∑ k ∈ Finset.Icc 1 n, Real.log (2 * (k:ℝ) - 1) := by
    rw [Real.log_prod]
    intro k hk; exact ne_of_gt (hfac k hk)
  have h2n1 : (0:ℝ) < 2 * (n:ℝ) - 1 := by
    have : (1:ℝ) ≤ n := by exact_mod_cast hn1
    linarith
  have h2n1' : (0:ℝ) < (2 * (n:ℝ) - 1) / Real.exp 1 := by positivity
  have h2n3' : (0:ℝ) < (2 * (n:ℝ) + 1) / Real.exp 1 := by positivity
  constructor
  · rw [Real.rpow_def_of_pos h2n1', ← Real.exp_log hP, Real.exp_lt_exp, hlogP,
      Real.log_div (ne_of_gt h2n1) (Real.exp_ne_zero 1), Real.log_exp]
    nlinarith [hlow]
  · rw [Real.rpow_def_of_pos h2n3', ← Real.exp_log hP, Real.exp_lt_exp, hlogP,
      Real.log_div (by positivity : (2 * (n:ℝ) + 1) ≠ 0) (Real.exp_ne_zero 1), Real.log_exp]
    nlinarith [hupp]
