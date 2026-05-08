import Mathlib

open Finset Real

private lemma prod_odds_pos (n : ℕ) :
    0 < ∏ k ∈ Finset.range n, (2 * (k : ℝ) + 1) := by
  apply Finset.prod_pos
  intro k _
  positivity

private lemma log_prod_odds_succ (n : ℕ) :
    Real.log (∏ k ∈ Finset.range (n+1), (2 * (k : ℝ) + 1)) =
      Real.log (∏ k ∈ Finset.range n, (2 * (k : ℝ) + 1)) + Real.log (2 * (n : ℝ) + 1) := by
  rw [Finset.prod_range_succ, Real.log_mul (prod_odds_pos n).ne' (by positivity)]

/-- Log version of the inequality: for `n ≥ 1`,
  `(2n-1)/2 * (log(2n-1) - 1) < log P(n) < (2n+1)/2 * (log(2n+1) - 1)`. -/
private lemma log_bound (n : ℕ) :
    (2 * ((n : ℝ) + 1) - 1) / 2 * (Real.log (2 * ((n : ℝ) + 1) - 1) - 1) <
        Real.log (∏ k ∈ Finset.range (n + 1), (2 * (k : ℝ) + 1)) ∧
    Real.log (∏ k ∈ Finset.range (n + 1), (2 * (k : ℝ) + 1)) <
        (2 * ((n : ℝ) + 1) + 1) / 2 * (Real.log (2 * ((n : ℝ) + 1) + 1) - 1) := by
  induction n with
  | zero =>
    have h1 : (∏ k ∈ Finset.range 1, (2 * (k : ℝ) + 1)) = 1 := by
      simp [Finset.prod_range_succ]
    refine ⟨?_, ?_⟩
    · rw [h1, Real.log_one]
      have : Real.log (2 * ((0 : ℕ) : ℝ) + 1) = 0 := by norm_num [Real.log_one]
      simp only [Nat.cast_zero, zero_add, mul_one]
      rw [show (2 * (0 + 1 : ℝ) - 1) = 1 by ring, Real.log_one]
      norm_num
    · rw [h1, Real.log_one]
      simp only [Nat.cast_zero, zero_add, mul_one]
      rw [show (2 * (0 + 1 : ℝ) + 1) = 3 by ring]
      have h3 : Real.log 3 > 1 := by
        have he : Real.exp 1 < 3 := by
          have := Real.exp_one_lt_d9
          linarith
        have := Real.log_lt_log (Real.exp_pos 1) he
        rwa [Real.log_exp] at this
      nlinarith [h3]
  | succ k ih =>
    obtain ⟨ih_low, ih_up⟩ := ih
    -- New product = old product * (2(k+1) + 1) = old * (2k+3)
    -- After Finset.prod_range_succ: ∏ range (k+2) = ∏ range (k+1) * (2(k+1) + 1)
    rw [show k + 1 + 1 = (k + 1) + 1 from rfl, log_prod_odds_succ]
    -- log new value: log P(k+1) + log(2(k+1)+1) = log P(k+1) + log(2k+3)
    have h2k3pos : (0 : ℝ) < 2 * ((k : ℝ) + 1) + 1 := by positivity
    have h2k1pos : (0 : ℝ) < 2 * ((k : ℝ) + 1) - 1 := by
      have : (1 : ℝ) ≤ 2 * ((k : ℝ) + 1) - 1 := by
        have hk : (0 : ℝ) ≤ (k : ℝ) := by positivity
        linarith
      linarith
    have h2k5pos : (0 : ℝ) < 2 * ((k : ℝ) + 1 + 1) + 1 := by positivity
    have h2k3pos' : (0 : ℝ) < 2 * ((k : ℝ) + 1 + 1) - 1 := by
      have hk : (0 : ℝ) ≤ (k : ℝ) := by positivity
      linarith
    refine ⟨?_, ?_⟩
    · -- Lower: (2(k+2)-1)/2 * (log(2(k+2)-1) - 1) < log P + log(2k+3)
      -- I.e. (2k+3)/2 * (log(2k+3) - 1) < log P + log(2k+3)
      -- Need (2k+3)/2 * (log(2k+3) - 1) - log(2k+3) < log P
      -- I.e. (2k+1)/2 * log(2k+3) - (2k+3)/2 < log P
      -- IH gives (2k+1)/2 * (log(2k+1) - 1) < log P
      -- Suffices: (2k+1)/2 * log(2k+3) - (2k+3)/2 ≤ (2k+1)/2 * (log(2k+1) - 1)
      -- I.e. (2k+1)/2 * (log(2k+3) - log(2k+1)) ≤ (2k+3)/2 - (2k+1)/2 = 1
      -- I.e. (2k+1) * log((2k+3)/(2k+1)) ≤ 2
      -- I.e. log(1 + 2/(2k+1)) ≤ 2/(2k+1) -- standard log inequality
      have hu : (2 * ((k : ℝ) + 1) + 1) / (2 * ((k : ℝ) + 1) - 1) > 1 := by
        rw [gt_iff_lt, lt_div_iff h2k1pos]
        linarith
      have hu_pos : (2 * ((k : ℝ) + 1) + 1) / (2 * ((k : ℝ) + 1) - 1) > 0 := by linarith
      have hu_ne : (2 * ((k : ℝ) + 1) + 1) / (2 * ((k : ℝ) + 1) - 1) ≠ 1 := ne_of_gt hu
      -- log u < u - 1
      have hlog : Real.log ((2 * ((k : ℝ) + 1) + 1) / (2 * ((k : ℝ) + 1) - 1)) <
          (2 * ((k : ℝ) + 1) + 1) / (2 * ((k : ℝ) + 1) - 1) - 1 :=
        Real.log_lt_sub_one_of_ne hu_ne hu_pos
      have hlog_split : Real.log ((2 * ((k : ℝ) + 1) + 1) / (2 * ((k : ℝ) + 1) - 1)) =
          Real.log (2 * ((k : ℝ) + 1) + 1) - Real.log (2 * ((k : ℝ) + 1) - 1) := by
        rw [Real.log_div h2k3pos.ne' h2k1pos.ne']
      rw [hlog_split] at hlog
      have hsub_eq : (2 * ((k : ℝ) + 1) + 1) / (2 * ((k : ℝ) + 1) - 1) - 1 =
          2 / (2 * ((k : ℝ) + 1) - 1) := by
        field_simp
      rw [hsub_eq] at hlog
      -- Now hlog: log(2k+3) - log(2k+1) < 2/(2k+1)
      -- Multiply both sides by (2k+1)/2 (positive):
      -- (2k+1)/2 * (log(2k+3) - log(2k+1)) < 1
      have hmul : (2 * ((k : ℝ) + 1) - 1) / 2 *
          (Real.log (2 * ((k : ℝ) + 1) + 1) - Real.log (2 * ((k : ℝ) + 1) - 1)) < 1 := by
        have h1 : (2 * ((k : ℝ) + 1) - 1) / 2 *
            (Real.log (2 * ((k : ℝ) + 1) + 1) - Real.log (2 * ((k : ℝ) + 1) - 1)) <
            (2 * ((k : ℝ) + 1) - 1) / 2 * (2 / (2 * ((k : ℝ) + 1) - 1)) := by
          apply (mul_lt_mul_left (by linarith : (0:ℝ) < (2 * ((k : ℝ) + 1) - 1) / 2)).mpr hlog
        have h2 : (2 * ((k : ℝ) + 1) - 1) / 2 * (2 / (2 * ((k : ℝ) + 1) - 1)) = 1 := by
          field_simp
        linarith
      -- So: (2k+1)/2 * log(2k+3) - (2k+1)/2 * log(2k+1) < 1
      -- Need: (2(k+2)-1)/2 * (log(2(k+2)-1) - 1) < log P + log(2k+3)
      -- where 2(k+2)-1 = 2k+3
      have eq1 : 2 * ((k : ℝ) + 1 + 1) - 1 = 2 * ((k : ℝ) + 1) + 1 := by ring
      rw [eq1]
      -- IH: (2k+1)/2 * (log(2k+1) - 1) < log P
      -- We want: (2k+3)/2 * (log(2k+3) - 1) < log P + log(2k+3)
      -- Equivalently: (2k+3)/2 * log(2k+3) - (2k+3)/2 - log(2k+3) < log P
      -- I.e. ((2k+3)/2 - 1) * log(2k+3) - (2k+3)/2 < log P
      -- I.e. (2k+1)/2 * log(2k+3) - (2k+3)/2 < log P
      -- Have IH + need: (2k+1)/2 * log(2k+3) - (2k+3)/2 ≤ (2k+1)/2 * (log(2k+1) - 1)
      -- I.e. (2k+1)/2 * (log(2k+3) - log(2k+1)) ≤ (2k+3)/2 - (2k+1)/2 = 1
      -- This is exactly hmul (with ≤, but we have <).
      nlinarith [hmul, ih_low]
    · -- Upper: log P + log(2k+3) < (2(k+2)+1)/2 * (log(2(k+2)+1) - 1)
      -- I.e. log P + log(2k+3) < (2k+5)/2 * (log(2k+5) - 1)
      -- IH: log P < (2k+3)/2 * (log(2k+3) - 1)
      -- Suffices: (2k+3)/2 * (log(2k+3) - 1) + log(2k+3) ≤ (2k+5)/2 * (log(2k+5) - 1)
      -- LHS = (2k+5)/2 * log(2k+3) - (2k+3)/2
      -- RHS = (2k+5)/2 * log(2k+5) - (2k+5)/2
      -- Diff = (2k+5)/2 * (log(2k+5) - log(2k+3)) - 1
      -- Want diff ≥ 0, i.e. (2k+5) * log((2k+5)/(2k+3)) ≥ 2
      -- I.e. log((2k+3)/(2k+5)) ≤ -2/(2k+5), i.e. log(v) < v - 1 for v < 1
      -- v = (2k+3)/(2k+5) < 1
      have hv : (2 * ((k : ℝ) + 1) + 1) / (2 * ((k : ℝ) + 1 + 1) + 1) < 1 := by
        rw [div_lt_one h2k5pos]
        linarith
      have hv_pos : (2 * ((k : ℝ) + 1) + 1) / (2 * ((k : ℝ) + 1 + 1) + 1) > 0 := by
        positivity
      have hv_ne : (2 * ((k : ℝ) + 1) + 1) / (2 * ((k : ℝ) + 1 + 1) + 1) ≠ 1 := ne_of_lt hv
      have hlog : Real.log ((2 * ((k : ℝ) + 1) + 1) / (2 * ((k : ℝ) + 1 + 1) + 1)) <
          (2 * ((k : ℝ) + 1) + 1) / (2 * ((k : ℝ) + 1 + 1) + 1) - 1 :=
        Real.log_lt_sub_one_of_ne hv_ne hv_pos
      have hlog_split : Real.log ((2 * ((k : ℝ) + 1) + 1) / (2 * ((k : ℝ) + 1 + 1) + 1)) =
          Real.log (2 * ((k : ℝ) + 1) + 1) - Real.log (2 * ((k : ℝ) + 1 + 1) + 1) := by
        rw [Real.log_div h2k3pos.ne' h2k5pos.ne']
      rw [hlog_split] at hlog
      have hsub_eq : (2 * ((k : ℝ) + 1) + 1) / (2 * ((k : ℝ) + 1 + 1) + 1) - 1 =
          -2 / (2 * ((k : ℝ) + 1 + 1) + 1) := by
        field_simp
      rw [hsub_eq] at hlog
      -- Now: log(2k+3) - log(2k+5) < -2/(2k+5)
      -- I.e. log(2k+5) - log(2k+3) > 2/(2k+5)
      -- Multiply by (2k+5)/2 > 0:
      -- (2k+5)/2 * (log(2k+5) - log(2k+3)) > 1
      have h2k5pos' : (0 : ℝ) < 2 * ((k : ℝ) + 1 + 1) + 1 := h2k5pos
      have hmul : (2 * ((k : ℝ) + 1 + 1) + 1) / 2 *
          (Real.log (2 * ((k : ℝ) + 1 + 1) + 1) - Real.log (2 * ((k : ℝ) + 1) + 1)) > 1 := by
        have h1 : Real.log (2 * ((k : ℝ) + 1 + 1) + 1) - Real.log (2 * ((k : ℝ) + 1) + 1) >
            2 / (2 * ((k : ℝ) + 1 + 1) + 1) := by linarith
        have h2 : (2 * ((k : ℝ) + 1 + 1) + 1) / 2 *
            (2 / (2 * ((k : ℝ) + 1 + 1) + 1)) = 1 := by field_simp
        have h3 : (2 * ((k : ℝ) + 1 + 1) + 1) / 2 *
            (Real.log (2 * ((k : ℝ) + 1 + 1) + 1) - Real.log (2 * ((k : ℝ) + 1) + 1)) >
            (2 * ((k : ℝ) + 1 + 1) + 1) / 2 *
            (2 / (2 * ((k : ℝ) + 1 + 1) + 1)) := by
          apply (mul_lt_mul_left (by linarith : (0:ℝ) < (2 * ((k : ℝ) + 1 + 1) + 1) / 2)).mpr h1
        linarith
      nlinarith [hmul, ih_up]

theorem putnam_1996_b2 (n : ℕ) (hn : 0 < n) :
    ((2 * (n : ℝ) - 1) / Real.exp 1) ^ ((2 * (n : ℝ) - 1) / 2) <
        ∏ k ∈ Finset.range n, (2 * (k : ℝ) + 1) ∧
    (∏ k ∈ Finset.range n, (2 * (k : ℝ) + 1)) <
        ((2 * (n : ℝ) + 1) / Real.exp 1) ^ ((2 * (n : ℝ) + 1) / 2) := by
  obtain ⟨m, rfl⟩ := Nat.exists_eq_succ_of_ne_zero hn.ne'
  obtain ⟨hlow, hup⟩ := log_bound m
  have hP_pos : 0 < ∏ k ∈ Finset.range (m + 1), (2 * (k : ℝ) + 1) := prod_odds_pos _
  have h2m1pos : (0 : ℝ) < 2 * (((m : ℕ) : ℝ) + 1) - 1 := by
    have : (0 : ℝ) ≤ (m : ℝ) := by positivity
    linarith
  have h2m3pos : (0 : ℝ) < 2 * (((m : ℕ) : ℝ) + 1) + 1 := by positivity
  -- Convert n = m+1 to suit the form 2n-1, 2n+1
  have hn_eq : (((m + 1 : ℕ) : ℝ)) = (m : ℝ) + 1 := by push_cast; ring
  -- Now connect log_bound to the rpow form.
  -- (a/e)^b = exp(b * log(a/e)) = exp(b * (log a - 1))
  -- where a = 2n-1 or 2n+1 and b = a/2.
  -- So (a/e)^(a/2) = exp(a/2 * (log a - 1)).
  refine ⟨?_, ?_⟩
  · -- Lower: ((2n-1)/e)^((2n-1)/2) < P
    -- log P > (2n-1)/2 * (log(2n-1) - 1) = log of the LHS when (2n-1) > 0
    have hbase_pos : (0 : ℝ) < (2 * (((m + 1 : ℕ) : ℝ)) - 1) / Real.exp 1 := by
      rw [hn_eq]; exact div_pos h2m1pos (Real.exp_pos 1)
    have hlhs : ((2 * (((m + 1 : ℕ) : ℝ)) - 1) / Real.exp 1) ^
        ((2 * (((m + 1 : ℕ) : ℝ)) - 1) / 2) =
        Real.exp ((2 * (((m + 1 : ℕ) : ℝ)) - 1) / 2 *
          (Real.log (2 * (((m + 1 : ℕ) : ℝ)) - 1) - 1)) := by
      rw [Real.rpow_def_of_pos hbase_pos]
      congr 1
      rw [Real.log_div h2m1pos.ne' (Real.exp_pos 1).ne', Real.log_exp]
      rw [hn_eq]; ring
    rw [hlhs]
    -- exp(log_bound) < exp(log P) = P
    have hlogP : Real.log (∏ k ∈ Finset.range (m + 1), (2 * (k : ℝ) + 1)) =
        Real.log (∏ k ∈ Finset.range (m + 1), (2 * (k : ℝ) + 1)) := rfl
    have h1 : Real.exp ((2 * (((m + 1 : ℕ) : ℝ)) - 1) / 2 *
        (Real.log (2 * (((m + 1 : ℕ) : ℝ)) - 1) - 1)) <
        Real.exp (Real.log (∏ k ∈ Finset.range (m + 1), (2 * (k : ℝ) + 1))) := by
      apply Real.exp_lt_exp.mpr
      rw [hn_eq]
      convert hlow using 2
    rw [Real.exp_log hP_pos] at h1
    exact h1
  · -- Upper: P < ((2n+1)/e)^((2n+1)/2)
    have hbase_pos : (0 : ℝ) < (2 * (((m + 1 : ℕ) : ℝ)) + 1) / Real.exp 1 := by
      rw [hn_eq]; exact div_pos h2m3pos (Real.exp_pos 1)
    have hrhs : ((2 * (((m + 1 : ℕ) : ℝ)) + 1) / Real.exp 1) ^
        ((2 * (((m + 1 : ℕ) : ℝ)) + 1) / 2) =
        Real.exp ((2 * (((m + 1 : ℕ) : ℝ)) + 1) / 2 *
          (Real.log (2 * (((m + 1 : ℕ) : ℝ)) + 1) - 1)) := by
      rw [Real.rpow_def_of_pos hbase_pos]
      congr 1
      rw [Real.log_div h2m3pos.ne' (Real.exp_pos 1).ne', Real.log_exp]
      rw [hn_eq]; ring
    rw [hrhs]
    have h1 : Real.exp (Real.log (∏ k ∈ Finset.range (m + 1), (2 * (k : ℝ) + 1))) <
        Real.exp ((2 * (((m + 1 : ℕ) : ℝ)) + 1) / 2 *
          (Real.log (2 * (((m + 1 : ℕ) : ℝ)) + 1) - 1)) := by
      apply Real.exp_lt_exp.mpr
      rw [hn_eq]
      convert hup using 2
    rw [Real.exp_log hP_pos] at h1
    exact h1
