import Mathlib

open Real Finset

theorem putnam_1996_b2 (n : ℕ) (hn : 0 < n) :
    ((2 * (n : ℝ) - 1) / Real.exp 1) ^ ((2 * (n : ℝ) - 1) / 2)
      < ∏ i ∈ Finset.range n, (2 * (i : ℝ) + 1)
    ∧ (∏ i ∈ Finset.range n, (2 * (i : ℝ) + 1))
      < ((2 * (n : ℝ) + 1) / Real.exp 1) ^ ((2 * (n : ℝ) + 1) / 2) := by
  -- rewrite G(x) = (x/e)^(x/2) in exponential form
  have hGexp : ∀ x : ℝ, 0 < x →
      (x / Real.exp 1) ^ (x / 2) = Real.exp ((Real.log x - 1) * (x / 2)) := by
    intro x hx
    rw [Real.rpow_def_of_pos (by positivity),
        Real.log_div (ne_of_gt hx) (Real.exp_ne_zero 1), Real.log_exp]
  -- step for the upper bound:  G(x) * x ≤ G(x+2)
  have step_up : ∀ x : ℝ, 1 ≤ x →
      (x / Real.exp 1) ^ (x / 2) * x ≤ ((x + 2) / Real.exp 1) ^ ((x + 2) / 2) := by
    intro x hx
    have hx0 : 0 < x := by linarith
    have hx2 : 0 < x + 2 := by linarith
    rw [hGexp x hx0, hGexp (x + 2) hx2]
    have h1 : 2 / (x + 2) ≤ Real.log (x + 2) - Real.log x := by
      have h := Real.log_le_sub_one_of_pos (show (0:ℝ) < x / (x + 2) by positivity)
      rw [Real.log_div (ne_of_gt hx0) (ne_of_gt hx2)] at h
      have e1 : x / (x + 2) - 1 = -(2 / (x + 2)) := by field_simp; ring
      rw [e1] at h; linarith
    have hk : 2 ≤ (Real.log (x + 2) - Real.log x) * (x + 2) := (div_le_iff₀ hx2).mp h1
    have key : (Real.log x - 1) * (x / 2) + Real.log x
        ≤ (Real.log (x + 2) - 1) * ((x + 2) / 2) := by nlinarith [hk]
    calc Real.exp ((Real.log x - 1) * (x / 2)) * x
        = Real.exp ((Real.log x - 1) * (x / 2)) * Real.exp (Real.log x) := by
          rw [Real.exp_log hx0]
      _ = Real.exp ((Real.log x - 1) * (x / 2) + Real.log x) := by rw [← Real.exp_add]
      _ ≤ Real.exp ((Real.log (x + 2) - 1) * ((x + 2) / 2)) := by
          rw [Real.exp_le_exp]; exact key
  -- step for the lower bound:  G(x+2) ≤ G(x) * (x+2)
  have step_low : ∀ x : ℝ, 1 ≤ x →
      ((x + 2) / Real.exp 1) ^ ((x + 2) / 2) ≤ (x / Real.exp 1) ^ (x / 2) * (x + 2) := by
    intro x hx
    have hx0 : 0 < x := by linarith
    have hx2 : 0 < x + 2 := by linarith
    rw [hGexp x hx0, hGexp (x + 2) hx2]
    have h1 : Real.log (x + 2) - Real.log x ≤ 2 / x := by
      have h := Real.log_le_sub_one_of_pos (show (0:ℝ) < (x + 2) / x by positivity)
      rw [Real.log_div (ne_of_gt hx2) (ne_of_gt hx0)] at h
      have e1 : (x + 2) / x - 1 = 2 / x := by field_simp; ring
      rw [e1] at h; linarith
    have hk : (Real.log (x + 2) - Real.log x) * x ≤ 2 := (le_div_iff₀ hx0).mp h1
    have key : (Real.log (x + 2) - 1) * ((x + 2) / 2)
        ≤ (Real.log x - 1) * (x / 2) + Real.log (x + 2) := by nlinarith [hk]
    calc Real.exp ((Real.log (x + 2) - 1) * ((x + 2) / 2))
        ≤ Real.exp ((Real.log x - 1) * (x / 2) + Real.log (x + 2)) := by
          rw [Real.exp_le_exp]; exact key
      _ = Real.exp ((Real.log x - 1) * (x / 2)) * Real.exp (Real.log (x + 2)) := by
          rw [Real.exp_add]
      _ = Real.exp ((Real.log x - 1) * (x / 2)) * (x + 2) := by rw [Real.exp_log hx2]
  -- upper bound by induction
  have hup : ∀ m : ℕ, 1 ≤ m →
      (∏ i ∈ Finset.range m, (2 * (i : ℝ) + 1))
        < ((2 * (m : ℝ) + 1) / Real.exp 1) ^ ((2 * (m : ℝ) + 1) / 2) := by
    intro m hm
    induction m, hm using Nat.le_induction with
    | base =>
      rw [Finset.prod_range_one]
      have : (1:ℝ) < (3 / Real.exp 1) ^ ((3:ℝ) / 2) := by
        apply (Real.one_lt_rpow_iff_of_pos (by positivity)).mpr
        left
        refine ⟨?_, by norm_num⟩
        rw [lt_div_iff₀ (Real.exp_pos 1)]
        nlinarith [Real.exp_one_lt_d9]
      norm_num
      convert this using 2 <;> norm_num
    | succ n hn ih =>
      rw [Finset.prod_range_succ]
      have hpos : (0:ℝ) < 2 * (n : ℝ) + 1 := by positivity
      have hxge : (1:ℝ) ≤ 2 * (n : ℝ) + 1 := by
        have : (1:ℝ) ≤ (n : ℝ) := by exact_mod_cast hn
        linarith
      have h2 : (∏ i ∈ Finset.range n, (2 * (i : ℝ) + 1)) * (2 * (n : ℝ) + 1)
          < ((2 * (n : ℝ) + 1) / Real.exp 1) ^ ((2 * (n : ℝ) + 1) / 2) * (2 * (n : ℝ) + 1) :=
        mul_lt_mul_of_pos_right ih hpos
      have h3 := step_up (2 * (n : ℝ) + 1) hxge
      calc (∏ i ∈ Finset.range n, (2 * (i : ℝ) + 1)) * (2 * (n : ℝ) + 1)
          < ((2 * (n : ℝ) + 1) / Real.exp 1) ^ ((2 * (n : ℝ) + 1) / 2) * (2 * (n : ℝ) + 1) := h2
        _ ≤ (((2 * (n : ℝ) + 1) + 2) / Real.exp 1) ^ (((2 * (n : ℝ) + 1) + 2) / 2) := h3
        _ = ((2 * ((n : ℝ) + 1) + 1) / Real.exp 1) ^ ((2 * ((n : ℝ) + 1) + 1) / 2) := by
            congr 1 <;> ring
        _ = ((2 * ((n + 1 : ℕ) : ℝ) + 1) / Real.exp 1) ^ ((2 * ((n + 1 : ℕ) : ℝ) + 1) / 2) := by
            push_cast; ring_nf
  -- lower bound by induction
  have hlow : ∀ m : ℕ, 1 ≤ m →
      ((2 * (m : ℝ) - 1) / Real.exp 1) ^ ((2 * (m : ℝ) - 1) / 2)
        < ∏ i ∈ Finset.range m, (2 * (i : ℝ) + 1) := by
    intro m hm
    induction m, hm using Nat.le_induction with
    | base =>
      rw [Finset.prod_range_one]
      have : (1 / Real.exp 1) ^ ((1:ℝ) / 2) < 1 := by
        apply Real.rpow_lt_one (by positivity) _ (by norm_num)
        rw [div_lt_one (Real.exp_pos 1)]
        nlinarith [Real.exp_one_gt_d9]
      norm_num
      convert this using 2 <;> norm_num
    | succ n hn ih =>
      rw [Finset.prod_range_succ]
      have hpos : (0:ℝ) < 2 * (n : ℝ) + 1 := by positivity
      have hxge : (1:ℝ) ≤ 2 * (n : ℝ) - 1 := by
        have : (1:ℝ) ≤ (n : ℝ) := by exact_mod_cast hn
        linarith
      have h3 := step_low (2 * (n : ℝ) - 1) hxge
      have h2 : ((2 * (n : ℝ) - 1) / Real.exp 1) ^ ((2 * (n : ℝ) - 1) / 2) * (2 * (n : ℝ) + 1)
          < (∏ i ∈ Finset.range n, (2 * (i : ℝ) + 1)) * (2 * (n : ℝ) + 1) :=
        mul_lt_mul_of_pos_right ih hpos
      calc ((2 * ((n + 1 : ℕ) : ℝ) - 1) / Real.exp 1) ^ ((2 * ((n + 1 : ℕ) : ℝ) - 1) / 2)
          = (((2 * (n : ℝ) - 1) + 2) / Real.exp 1) ^ (((2 * (n : ℝ) - 1) + 2) / 2) := by
            push_cast; congr 1 <;> ring
        _ ≤ ((2 * (n : ℝ) - 1) / Real.exp 1) ^ ((2 * (n : ℝ) - 1) / 2) * ((2 * (n : ℝ) - 1) + 2) := h3
        _ = ((2 * (n : ℝ) - 1) / Real.exp 1) ^ ((2 * (n : ℝ) - 1) / 2) * (2 * (n : ℝ) + 1) := by
            ring
        _ < (∏ i ∈ Finset.range n, (2 * (i : ℝ) + 1)) * (2 * (n : ℝ) + 1) := h2
  exact ⟨hlow n hn, hup n hn⟩
