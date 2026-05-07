import Mathlib

open Real Finset

-- log(1 + y) < y for y > 0
private lemma log_one_add_lt {y : ℝ} (hy : 0 < y) : Real.log (1 + y) < y := by
  have h1 : (1 : ℝ) + y ≠ 1 := by linarith
  have h2 : (0 : ℝ) < 1 + y := by linarith
  have := Real.log_lt_sub_one_of_pos h2 h1
  linarith

-- log(1 + y) > y / (1 + y) for y > 0
private lemma log_one_add_gt {y : ℝ} (hy : 0 < y) : y / (1 + y) < Real.log (1 + y) := by
  have hpos : 0 < 1 + y := by linarith
  have hne : (-(y / (1 + y)) : ℝ) ≠ 0 := by
    have hd : y / (1 + y) ≠ 0 := div_ne_zero hy.ne' hpos.ne'
    exact neg_ne_zero.mpr hd
  have key := Real.add_one_lt_exp hne
  have h_simp : -(y / (1 + y)) + 1 = 1 / (1 + y) := by
    field_simp
    ring
  rw [h_simp] at key
  have hpos2 : (0 : ℝ) < 1 / (1 + y) := by positivity
  have h2 := Real.log_lt_log hpos2 key
  rw [Real.log_exp] at h2
  have h3 : Real.log (1 / (1 + y)) = -Real.log (1 + y) := by
    rw [Real.log_div one_ne_zero hpos.ne', Real.log_one, zero_sub]
  rw [h3] at h2
  linarith

-- Define g(x) = (x/2) * (log x - 1), so exp(g x) = (x/e)^(x/2) for x > 0
noncomputable def g (x : ℝ) : ℝ := (x / 2) * (Real.log x - 1)

private lemma exp_g (x : ℝ) (hx : 0 < x) :
    Real.exp (g x) = (x / Real.exp 1) ^ (x / 2) := by
  unfold g
  have hxe : (0 : ℝ) < x / Real.exp 1 := by positivity
  have heq1 : (x / 2) * (Real.log x - 1) = (x / 2) * Real.log (x / Real.exp 1) := by
    rw [Real.log_div hx.ne' (Real.exp_pos 1).ne', Real.log_exp]
  rw [heq1, ← Real.log_rpow hxe]
  exact Real.exp_log (Real.rpow_pos_of_pos hxe _)

-- Key induction step lemmas (logarithmic difference bounds)

-- For x ≥ 1: log(x+2) > g(x+2) - g(x), where g(x) = (x/2)(log x - 1)
-- Equivalent to: 1 > (x/2) * log(1 + 2/x)
private lemma g_step_lower {x : ℝ} (hx : 1 ≤ x) :
    g (x + 2) - g x < Real.log (x + 2) := by
  unfold g
  have hx0 : 0 < x := by linarith
  have hx2 : 0 < x + 2 := by linarith
  -- Need: (x+2)/2 * (log(x+2) - 1) - x/2 * (log x - 1) < log(x+2)
  -- i.e., (x/2)(log(x+2) - log x) < 1
  -- i.e., (x/2) * log(1 + 2/x) < 1
  -- Use log(1 + 2/x) < 2/x
  have hy : 0 < 2 / x := by positivity
  have hlog : Real.log (1 + 2/x) < 2/x := log_one_add_lt hy
  have heq : (1 : ℝ) + 2/x = (x + 2) / x := by field_simp
  rw [heq] at hlog
  rw [Real.log_div hx2.ne' hx0.ne'] at hlog
  -- log(x+2) - log x < 2/x
  -- multiply by x/2: (x/2) * (log(x+2) - log x) < 1
  have : (x / 2) * (Real.log (x + 2) - Real.log x) < 1 := by
    have := mul_lt_mul_of_pos_left hlog (by linarith : (0:ℝ) < x/2)
    have hcalc : (x / 2) * (2 / x) = 1 := by field_simp
    linarith
  linarith

-- For x ≥ 1: g(x+2) - g(x) > log x
-- Equivalent to: ((x+2)/2) * log(1 + 2/x) > 1
private lemma g_step_upper {x : ℝ} (hx : 1 ≤ x) :
    Real.log x < g (x + 2) - g x := by
  unfold g
  have hx0 : 0 < x := by linarith
  have hx2 : 0 < x + 2 := by linarith
  have hy : 0 < 2 / x := by positivity
  -- Use log(1 + 2/x) > (2/x) / (1 + 2/x) = 2/(x+2)
  have hlog := log_one_add_gt hy
  have heq1 : (1 : ℝ) + 2/x = (x + 2) / x := by field_simp
  have heq2 : (2/x) / (1 + 2/x) = 2 / (x + 2) := by
    rw [heq1]; field_simp
  rw [heq2, heq1] at hlog
  -- 2 / (x+2) < log((x+2)/x)
  rw [Real.log_div hx2.ne' hx0.ne'] at hlog
  -- 2/(x+2) < log(x+2) - log x
  -- multiply by (x+2)/2: 1 < ((x+2)/2) * (log(x+2) - log x)
  have hpos : 0 < (x + 2) / 2 := by linarith
  have hmult := mul_lt_mul_of_pos_left hlog hpos
  have hcalc : (x + 2) / 2 * (2 / (x + 2)) = 1 := by field_simp
  rw [hcalc] at hmult
  linarith

-- Main inequality on logs
private lemma log_ineq (n : ℕ) (hn : 0 < n) :
    g (2 * (n : ℝ) - 1) < ∑ k ∈ Finset.range n, Real.log ((2 * k + 1 : ℕ) : ℝ) ∧
      ∑ k ∈ Finset.range n, Real.log ((2 * k + 1 : ℕ) : ℝ) < g (2 * (n : ℝ) + 1) := by
  induction n, hn using Nat.le_induction with
  | base =>
    -- n = 1
    refine ⟨?_, ?_⟩
    · -- g(1) < log 1 = 0
      simp only [Finset.sum_range_one]
      unfold g
      norm_num
      -- (1/2)*(log 1 - 1) = (1/2)*(-1) = -1/2 < 0
    · -- log 1 < g(3) = (3/2)(log 3 - 1)
      simp only [Finset.sum_range_one]
      unfold g
      -- need: 0 < (3/2)(log 3 - 1), i.e., log 3 > 1
      have hexp : Real.exp 1 < 3 := by
        have := Real.exp_one_lt_d9
        linarith
      have hlog : 1 < Real.log 3 := by
        have h1 : Real.log (Real.exp 1) < Real.log 3 :=
          Real.log_lt_log (Real.exp_pos 1) hexp
        rw [Real.log_exp] at h1
        exact h1
      have : Real.log ((2 * (0:ℕ) + 1 : ℕ) : ℝ) = 0 := by simp
      rw [this]
      have h3 : (2 * ((1:ℕ):ℝ) + 1) / 2 = 3/2 := by norm_num
      rw [h3]
      have : Real.log (3 : ℝ) - 1 > 0 := by linarith
      have hpos : (3 / 2 : ℝ) > 0 := by norm_num
      nlinarith
  | succ n hn ih =>
    obtain ⟨ihL, ihU⟩ := ih
    -- Sum over range (n+1) = sum over range n + log(2n+1)
    have hsum_split :
        ∑ k ∈ Finset.range (n + 1), Real.log ((2 * k + 1 : ℕ) : ℝ) =
        (∑ k ∈ Finset.range n, Real.log ((2 * k + 1 : ℕ) : ℝ)) + Real.log ((2 * n + 1 : ℕ) : ℝ) := by
      rw [Finset.sum_range_succ]
    rw [hsum_split]
    -- We need:
    -- g(2(n+1)-1) < S + log(2n+1) and S + log(2n+1) < g(2(n+1)+1)
    -- 2(n+1)-1 = 2n+1, 2(n+1)+1 = 2n+3
    have h2n1 : (2 * ((n+1:ℕ):ℝ) - 1) = 2 * (n:ℝ) + 1 := by push_cast; ring
    have h2n3 : (2 * ((n+1:ℕ):ℝ) + 1) = 2 * (n:ℝ) + 3 := by push_cast; ring
    rw [h2n1, h2n3]
    have h_x_ge_one : (1 : ℝ) ≤ 2 * (n:ℝ) - 1 := by
      have : (1 : ℝ) ≤ (n : ℝ) := by exact_mod_cast hn
      linarith
    -- Apply g_step_upper at x = 2n-1, so x+2 = 2n+1
    have hupper_step := g_step_upper h_x_ge_one
    have heq_upper : (2 * (n:ℝ) - 1) + 2 = 2 * (n:ℝ) + 1 := by ring
    rw [heq_upper] at hupper_step
    -- hupper_step : log(2n-1) < g(2n+1) - g(2n-1)
    -- combine with ihL: g(2n-1) < S => g(2n+1) > g(2n-1) + log(2n-1)... hmm wait
    -- Actually: ihL: g(2n-1) < S
    -- Need: g(2n+1) < S + log(2n+1)
    -- From g_step_upper: g(2n+1) - g(2n-1) > log(2n-1)
    -- So g(2n+1) < g(2n-1) + ... wait, > sign
    -- Hmm, that gives lower bound on g(2n+1), not upper.
    --
    -- Let me reconsider. We need:
    -- g(2n+1) < S + log(2n+1)
    -- ihL says g(2n-1) < S, i.e., S > g(2n-1)
    -- So S + log(2n+1) > g(2n-1) + log(2n+1)
    -- We need g(2n+1) < g(2n-1) + log(2n+1)
    -- From g_step_lower at x = 2n-1: g(2n+1) - g(2n-1) < log(2n+1). YES!
    have hlower_step := g_step_lower h_x_ge_one
    rw [heq_upper] at hlower_step
    -- hlower_step : g(2n+1) - g(2n-1) < log(2n+1)
    have h_xp1_ge_one : (1 : ℝ) ≤ 2 * (n:ℝ) + 1 := by
      have : (0 : ℝ) ≤ (n : ℝ) := Nat.cast_nonneg _
      linarith
    -- Apply g_step_upper at x = 2n+1
    have hupper_step2 := g_step_upper h_xp1_ge_one
    have heq2 : (2 * (n:ℝ) + 1) + 2 = 2 * (n:ℝ) + 3 := by ring
    rw [heq2] at hupper_step2
    -- hupper_step2 : log(2n+1) < g(2n+3) - g(2n+1)
    -- Now bounds for n+1:
    -- LHS: g(2n+1) < S + log(2n+1)
    --   Have: g(2n+1) < g(2n-1) + log(2n+1) (from hlower_step)
    --         g(2n-1) < S (from ihL)
    --   So: g(2n+1) < S + log(2n+1) ✓
    -- RHS: S + log(2n+1) < g(2n+3)
    --   Have: S < g(2n+1) (from ihU)
    --         log(2n+1) < g(2n+3) - g(2n+1) (from hupper_step2)
    --   So: S + log(2n+1) < g(2n+1) + g(2n+3) - g(2n+1) = g(2n+3) ✓
    have hcast : ((2 * n + 1 : ℕ) : ℝ) = 2 * (n : ℝ) + 1 := by push_cast; ring
    rw [hcast]
    exact ⟨by linarith, by linarith⟩

theorem putnam_1996_b2 (n : ℕ) (hn : 0 < n) :
    ((2 * (n : ℝ) - 1) / Real.exp 1) ^ ((2 * (n : ℝ) - 1) / 2) <
        ∏ k ∈ Finset.range n, ((2 * k + 1 : ℕ) : ℝ) ∧
      ∏ k ∈ Finset.range n, ((2 * k + 1 : ℕ) : ℝ) <
        ((2 * (n : ℝ) + 1) / Real.exp 1) ^ ((2 * (n : ℝ) + 1) / 2) := by
  obtain ⟨hL, hU⟩ := log_ineq n hn
  have hprod_pos : 0 < ∏ k ∈ Finset.range n, ((2 * k + 1 : ℕ) : ℝ) := by
    apply Finset.prod_pos
    intros k _
    have : (0 : ℝ) < (2 * k + 1 : ℕ) := by positivity
    exact this
  have hsum_eq : ∑ k ∈ Finset.range n, Real.log ((2 * k + 1 : ℕ) : ℝ) =
      Real.log (∏ k ∈ Finset.range n, ((2 * k + 1 : ℕ) : ℝ)) := by
    rw [Real.log_prod]
    intros k _
    have : (0 : ℝ) < (2 * k + 1 : ℕ) := by positivity
    exact this.ne'
  rw [hsum_eq] at hL hU
  have h2nm1_pos : (0 : ℝ) < 2 * (n : ℝ) - 1 := by
    have : (1 : ℝ) ≤ (n : ℝ) := by exact_mod_cast hn
    linarith
  have h2np1_pos : (0 : ℝ) < 2 * (n : ℝ) + 1 := by positivity
  have hgL : Real.exp (g (2 * (n : ℝ) - 1)) =
      ((2 * (n : ℝ) - 1) / Real.exp 1) ^ ((2 * (n : ℝ) - 1) / 2) := exp_g _ h2nm1_pos
  have hgU : Real.exp (g (2 * (n : ℝ) + 1)) =
      ((2 * (n : ℝ) + 1) / Real.exp 1) ^ ((2 * (n : ℝ) + 1) / 2) := exp_g _ h2np1_pos
  refine ⟨?_, ?_⟩
  · -- (2n-1/e)^... < prod
    rw [← hgL]
    have h := Real.exp_lt_exp.mpr hL
    rw [Real.exp_log hprod_pos] at h
    exact h
  · -- prod < (2n+1/e)^...
    rw [← hgU]
    have h := Real.exp_lt_exp.mpr hU
    rw [Real.exp_log hprod_pos] at h
    exact h
