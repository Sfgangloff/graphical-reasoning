import Mathlib

open Finset

/-- Putnam 1996 B2: For every positive integer `n`,
    `((2n-1)/e)^((2n-1)/2) < 1·3·5···(2n-1) < ((2n+1)/e)^((2n+1)/2)`. -/
theorem putnam_1996_b2 (n : ℕ) (hn : 0 < n) :
    ((2 * (n : ℝ) - 1) / Real.exp 1) ^ ((2 * (n : ℝ) - 1) / 2) <
      ∏ k ∈ Finset.Icc 1 n, (2 * (k : ℝ) - 1) ∧
    ∏ k ∈ Finset.Icc 1 n, (2 * (k : ℝ) - 1) <
      ((2 * (n : ℝ) + 1) / Real.exp 1) ^ ((2 * (n : ℝ) + 1) / 2) := by
  -- each factor is positive
  have hfac : ∀ k ∈ Finset.Icc 1 n, (0:ℝ) < 2 * (k:ℝ) - 1 := by
    intro k hk
    have h1 : 1 ≤ k := (Finset.mem_Icc.mp hk).1
    have : (1:ℝ) ≤ (k:ℝ) := by exact_mod_cast h1
    linarith
  have hPpos : (0:ℝ) < ∏ k ∈ Finset.Icc 1 n, (2 * (k:ℝ) - 1) := Finset.prod_pos hfac
  have hlogP : Real.log (∏ k ∈ Finset.Icc 1 n, (2 * (k:ℝ) - 1))
      = ∑ k ∈ Finset.Icc 1 n, Real.log (2 * (k:ℝ) - 1) := by
    rw [Real.log_prod]
    intro k hk
    exact ne_of_gt (hfac k hk)
  -- core: both log inequalities, by induction starting at 1
  have key : ∀ m : ℕ, 1 ≤ m →
      (2 * (m:ℝ) - 1) / 2 * (Real.log (2 * (m:ℝ) - 1) - 1)
          < ∑ k ∈ Finset.Icc 1 m, Real.log (2 * (k:ℝ) - 1)
      ∧ ∑ k ∈ Finset.Icc 1 m, Real.log (2 * (k:ℝ) - 1)
          < (2 * (m:ℝ) + 1) / 2 * (Real.log (2 * (m:ℝ) + 1) - 1) := by
    intro m hm
    induction m, hm using Nat.le_induction with
    | base =>
      simp only [Finset.Icc_self, Finset.sum_singleton, Nat.cast_one]
      refine ⟨by norm_num [Real.log_one], ?_⟩
      have hexp : Real.exp 1 < 3 := by linarith [Real.exp_one_lt_d9]
      have h3 : (1:ℝ) < Real.log 3 := by
        calc (1:ℝ) = Real.log (Real.exp 1) := (Real.log_exp 1).symm
          _ < Real.log 3 := Real.log_lt_log (Real.exp_pos 1) hexp
      norm_num [Real.log_one]
      nlinarith [h3]
    | succ p hp ih =>
      have hq : (1:ℝ) ≤ (p:ℝ) := by exact_mod_cast hp
      obtain ⟨ihA, ihB⟩ := ih
      rw [Finset.sum_Icc_succ_top (show 1 ≤ p + 1 by omega)]
      have p1 : (0:ℝ) < 2*(p:ℝ)-1 := by linarith
      have p2 : (0:ℝ) < 2*(p:ℝ)+1 := by linarith
      have p3 : (0:ℝ) < 2*(p:ℝ)+3 := by linarith
      have p1' : (2*(p:ℝ)-1) ≠ 0 := ne_of_gt p1
      have p2' : (2*(p:ℝ)+1) ≠ 0 := ne_of_gt p2
      have p3' : (2*(p:ℝ)+3) ≠ 0 := ne_of_gt p3
      -- log differences via  log t ≤ t - 1
      have hA1 : Real.log (2*(p:ℝ)+1) - Real.log (2*(p:ℝ)-1) ≤ 2/(2*(p:ℝ)-1) := by
        have hd := Real.log_le_sub_one_of_pos (div_pos p2 p1)
        rw [Real.log_div p2' p1'] at hd
        have he : (2*(p:ℝ)+1)/(2*(p:ℝ)-1) - 1 = 2/(2*(p:ℝ)-1) := by field_simp; ring
        rw [he] at hd; exact hd
      have hB1 : 2/(2*(p:ℝ)+3) ≤ Real.log (2*(p:ℝ)+3) - Real.log (2*(p:ℝ)+1) := by
        have hd := Real.log_le_sub_one_of_pos (div_pos p2 p3)
        rw [Real.log_div p2' p3'] at hd
        have he : (2*(p:ℝ)+1)/(2*(p:ℝ)+3) - 1 = -(2/(2*(p:ℝ)+3)) := by field_simp; ring
        rw [he] at hd; linarith
      have mA : (2*(p:ℝ)-1) * (Real.log (2*(p:ℝ)+1) - Real.log (2*(p:ℝ)-1)) ≤ 2 := by
        calc (2*(p:ℝ)-1) * (Real.log (2*(p:ℝ)+1) - Real.log (2*(p:ℝ)-1))
            ≤ (2*(p:ℝ)-1) * (2/(2*(p:ℝ)-1)) := mul_le_mul_of_nonneg_left hA1 (le_of_lt p1)
          _ = 2 := by field_simp
      have mB : 2 ≤ (2*(p:ℝ)+3) * (Real.log (2*(p:ℝ)+3) - Real.log (2*(p:ℝ)+1)) := by
        calc (2:ℝ) = (2*(p:ℝ)+3) * (2/(2*(p:ℝ)+3)) := by field_simp
          _ ≤ (2*(p:ℝ)+3) * (Real.log (2*(p:ℝ)+3) - Real.log (2*(p:ℝ)+1)) :=
              mul_le_mul_of_nonneg_left hB1 (le_of_lt p3)
      refine ⟨?_, ?_⟩
      · push_cast
        rw [show (2*((p:ℝ)+1)-1) = 2*(p:ℝ)+1 from by ring]
        nlinarith [ihA, mA, p1, p2, hq]
      · push_cast
        rw [show (2*((p:ℝ)+1)+1) = 2*(p:ℝ)+3 from by ring,
            show (2*((p:ℝ)+1)-1) = 2*(p:ℝ)+1 from by ring]
        nlinarith [ihB, mB, p2, p3, hq]
  -- convert the log inequalities back to the rpow statement
  obtain ⟨kA, kB⟩ := key n hn
  rw [← hlogP] at kA kB
  have hn1 : (1:ℝ) ≤ (n:ℝ) := by exact_mod_cast hn
  have hnum1 : (0:ℝ) < 2*(n:ℝ)-1 := by linarith
  have hnum2 : (0:ℝ) < 2*(n:ℝ)+1 := by linarith
  have he1 : (0:ℝ) < Real.exp 1 := Real.exp_pos 1
  have hbl : (0:ℝ) < (2*(n:ℝ)-1)/Real.exp 1 := by positivity
  have hbu : (0:ℝ) < (2*(n:ℝ)+1)/Real.exp 1 := by positivity
  constructor
  · have hrp : (0:ℝ) < ((2*(n:ℝ)-1)/Real.exp 1) ^ ((2*(n:ℝ)-1)/2) :=
      Real.rpow_pos_of_pos hbl _
    have hlog : Real.log (((2*(n:ℝ)-1)/Real.exp 1) ^ ((2*(n:ℝ)-1)/2))
        < Real.log (∏ k ∈ Finset.Icc 1 n, (2*(k:ℝ)-1)) := by
      rw [Real.log_rpow hbl, Real.log_div (ne_of_gt hnum1) (ne_of_gt he1), Real.log_exp]
      linarith [kA]
    have := Real.exp_lt_exp.mpr hlog
    rwa [Real.exp_log hrp, Real.exp_log hPpos] at this
  · have hrp : (0:ℝ) < ((2*(n:ℝ)+1)/Real.exp 1) ^ ((2*(n:ℝ)+1)/2) :=
      Real.rpow_pos_of_pos hbu _
    have hlog : Real.log (∏ k ∈ Finset.Icc 1 n, (2*(k:ℝ)-1))
        < Real.log (((2*(n:ℝ)+1)/Real.exp 1) ^ ((2*(n:ℝ)+1)/2)) := by
      rw [Real.log_rpow hbu, Real.log_div (ne_of_gt hnum2) (ne_of_gt he1), Real.log_exp]
      linarith [kB]
    have := Real.exp_lt_exp.mpr hlog
    rwa [Real.exp_log hPpos, Real.exp_log hrp] at this
