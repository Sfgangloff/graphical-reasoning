import Mathlib

open Finset

/-- `G c = exp((log c - 1)·(c/2)) = (c/e)^(c/2)` for `c > 0`. -/
noncomputable def G (c : ℝ) : ℝ := Real.exp ((Real.log c - 1) * (c / 2))

private lemma G_rpow {c : ℝ} (hc : 0 < c) :
    (c / Real.exp 1) ^ (c / 2) = G c := by
  unfold G
  rw [Real.rpow_def_of_pos (by positivity),
      Real.log_div (ne_of_gt hc) (Real.exp_ne_zero 1), Real.log_exp]

private lemma G_stepA {c : ℝ} (hc : 0 < c) : G c * c ≤ G (c + 2) := by
  unfold G
  have hc2 : (0:ℝ) < c + 2 := by linarith
  have hx : (0:ℝ) < c / (c + 2) := by positivity
  have h1 : Real.log (c / (c + 2)) ≤ c / (c + 2) - 1 := Real.log_le_sub_one_of_pos hx
  have hlog : Real.log (c / (c + 2)) = Real.log c - Real.log (c + 2) :=
    Real.log_div (ne_of_gt hc) (ne_of_gt hc2)
  have hmul : (c + 2) * Real.log (c / (c + 2)) ≤ (c + 2) * (c / (c + 2) - 1) :=
    mul_le_mul_of_nonneg_left h1 (le_of_lt hc2)
  have heq : (c + 2) * (c / (c + 2) - 1) = -2 := by field_simp; ring
  rw [hlog, heq] at hmul
  have key : (Real.log c - 1) * (c / 2) + Real.log c
      ≤ (Real.log (c + 2) - 1) * ((c + 2) / 2) := by nlinarith [hmul]
  calc Real.exp ((Real.log c - 1) * (c / 2)) * c
      = Real.exp ((Real.log c - 1) * (c / 2)) * Real.exp (Real.log c) := by
        rw [Real.exp_log hc]
    _ = Real.exp ((Real.log c - 1) * (c / 2) + Real.log c) := by rw [← Real.exp_add]
    _ ≤ Real.exp ((Real.log (c + 2) - 1) * ((c + 2) / 2)) := Real.exp_le_exp.mpr key

private lemma G_stepB {c : ℝ} (hc : 0 < c) : G (c + 2) ≤ G c * (c + 2) := by
  unfold G
  have hc2 : (0:ℝ) < c + 2 := by linarith
  have hx : (0:ℝ) < (c + 2) / c := by positivity
  have h1 : Real.log ((c + 2) / c) ≤ (c + 2) / c - 1 := Real.log_le_sub_one_of_pos hx
  have hlog : Real.log ((c + 2) / c) = Real.log (c + 2) - Real.log c :=
    Real.log_div (ne_of_gt hc2) (ne_of_gt hc)
  have hmul : c * Real.log ((c + 2) / c) ≤ c * ((c + 2) / c - 1) :=
    mul_le_mul_of_nonneg_left h1 (le_of_lt hc)
  have heq : c * ((c + 2) / c - 1) = 2 := by field_simp; ring
  rw [hlog, heq] at hmul
  have key : (Real.log (c + 2) - 1) * ((c + 2) / 2)
      ≤ (Real.log c - 1) * (c / 2) + Real.log (c + 2) := by nlinarith [hmul]
  calc Real.exp ((Real.log (c + 2) - 1) * ((c + 2) / 2))
      ≤ Real.exp ((Real.log c - 1) * (c / 2) + Real.log (c + 2)) := Real.exp_le_exp.mpr key
    _ = Real.exp ((Real.log c - 1) * (c / 2)) * Real.exp (Real.log (c + 2)) := by
        rw [Real.exp_add]
    _ = Real.exp ((Real.log c - 1) * (c / 2)) * (c + 2) := by rw [Real.exp_log hc2]

/-- 1996 B2: For every positive integer `n`,
`((2n-1)/e)^((2n-1)/2) < 1·3·5···(2n-1) < ((2n+1)/e)^((2n+1)/2)`. -/
theorem putnam_1996_b2 (n : ℕ) (hn : 0 < n) :
    ((2 * (n : ℝ) - 1) / Real.exp 1) ^ ((2 * (n : ℝ) - 1) / 2)
        < ∏ i ∈ Finset.range n, (2 * (i : ℝ) + 1)
      ∧ (∏ i ∈ Finset.range n, (2 * (i : ℝ) + 1))
        < ((2 * (n : ℝ) + 1) / Real.exp 1) ^ ((2 * (n : ℝ) + 1) / 2) := by
  have hn1 : 1 ≤ n := hn
  -- Upper bound by induction
  have hUpper : ∀ m : ℕ, 1 ≤ m →
      (∏ i ∈ Finset.range m, (2 * (i : ℝ) + 1)) < G (2 * (m : ℝ) + 1) := by
    intro m hm
    induction m, hm using Nat.le_induction with
    | base =>
        have hP1 : (∏ i ∈ Finset.range 1, (2 * (i : ℝ) + 1)) = 1 := by simp
        rw [hP1]
        have he3 : Real.exp 1 < 3 := by have := Real.exp_one_lt_d9; linarith
        have hlog3 : (1:ℝ) < Real.log 3 := by
          have h := Real.log_lt_log (Real.exp_pos 1) he3
          rwa [Real.log_exp] at h
        unfold G
        have e1 : (2 * ((1:ℕ) : ℝ) + 1) = 3 := by norm_num
        rw [e1]
        have hpos : (0:ℝ) < (Real.log 3 - 1) * (3 / 2) := by nlinarith [hlog3]
        calc (1:ℝ) = Real.exp 0 := (Real.exp_zero).symm
          _ < Real.exp ((Real.log 3 - 1) * (3 / 2)) := Real.exp_lt_exp.mpr hpos
    | succ k hk ih =>
        have hc : (0:ℝ) < 2 * (k : ℝ) + 1 := by positivity
        rw [Finset.prod_range_succ]
        have h1 : (∏ i ∈ Finset.range k, (2 * (i : ℝ) + 1)) * (2 * (k : ℝ) + 1)
            < G (2 * (k : ℝ) + 1) * (2 * (k : ℝ) + 1) :=
          mul_lt_mul_of_pos_right ih hc
        have h2 : G (2 * (k : ℝ) + 1) * (2 * (k : ℝ) + 1) ≤ G ((2 * (k : ℝ) + 1) + 2) :=
          G_stepA hc
        have hge : G ((2 * (k : ℝ) + 1) + 2) = G (2 * ((k + 1 : ℕ) : ℝ) + 1) := by
          congr 1; push_cast; ring
        rw [hge] at h2
        exact lt_of_lt_of_le h1 h2
  -- Lower bound by induction
  have hLower : ∀ m : ℕ, 1 ≤ m →
      G (2 * (m : ℝ) - 1) < (∏ i ∈ Finset.range m, (2 * (i : ℝ) + 1)) := by
    intro m hm
    induction m, hm using Nat.le_induction with
    | base =>
        have hP1 : (∏ i ∈ Finset.range 1, (2 * (i : ℝ) + 1)) = 1 := by simp
        rw [hP1]
        unfold G
        have e1 : (2 * ((1:ℕ) : ℝ) - 1) = 1 := by norm_num
        rw [e1, Real.log_one]
        calc Real.exp (((0:ℝ) - 1) * (1 / 2)) < Real.exp 0 :=
              Real.exp_lt_exp.mpr (by norm_num)
          _ = 1 := Real.exp_zero
    | succ k hk ih =>
        have hkR : (1:ℝ) ≤ (k : ℝ) := by exact_mod_cast hk
        have hc : (0:ℝ) < 2 * (k : ℝ) - 1 := by linarith
        have h2k1 : (0:ℝ) < 2 * (k : ℝ) + 1 := by positivity
        rw [Finset.prod_range_succ]
        have h2 : G ((2 * (k : ℝ) - 1) + 2)
            ≤ G (2 * (k : ℝ) - 1) * ((2 * (k : ℝ) - 1) + 2) := G_stepB hc
        have hsimp : (2 * (k : ℝ) - 1) + 2 = 2 * (k : ℝ) + 1 := by ring
        rw [hsimp] at h2
        have h1 : G (2 * (k : ℝ) - 1) * (2 * (k : ℝ) + 1)
            < (∏ i ∈ Finset.range k, (2 * (i : ℝ) + 1)) * (2 * (k : ℝ) + 1) :=
          mul_lt_mul_of_pos_right ih h2k1
        have hcast : G (2 * ((k + 1 : ℕ) : ℝ) - 1) = G (2 * (k : ℝ) + 1) := by
          congr 1; push_cast; ring
        rw [hcast]
        exact lt_of_le_of_lt h2 h1
  -- Conclude
  have hbR : (0:ℝ) < 2 * (n : ℝ) + 1 := by positivity
  have hbL : (0:ℝ) < 2 * (n : ℝ) - 1 := by
    have : (1:ℝ) ≤ (n : ℝ) := by exact_mod_cast hn1
    linarith
  refine ⟨?_, ?_⟩
  · rw [G_rpow hbL]; exact hLower n hn1
  · rw [G_rpow hbR]; exact hUpper n hn1
