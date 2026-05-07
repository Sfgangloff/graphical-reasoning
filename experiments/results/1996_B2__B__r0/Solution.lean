import Mathlib

open Real Finset

-- For x > 0, log(1+x) < x
private lemma log_one_add_lt' (x : ℝ) (hx : 0 < x) : Real.log (1 + x) < x := by
  have h1 : (0 : ℝ) < 1 + x := by linarith
  have h2 : x ≠ 0 := ne_of_gt hx
  have h3 : x + 1 < Real.exp x := Real.add_one_lt_exp h2
  have h4 : 1 + x < Real.exp x := by linarith
  have := Real.log_lt_log h1 h4
  rwa [Real.log_exp] at this

-- Aux 1: For m > 0, (1 + 2/m)^(m/2) < e
private lemma aux_rpow_lt_e (m : ℝ) (hm : 0 < m) :
    (1 + 2/m) ^ (m/2) < Real.exp 1 := by
  have h2m : 0 < 2/m := by positivity
  have hlog : Real.log (1 + 2/m) < 2/m := log_one_add_lt' _ h2m
  have hbase : 0 < 1 + 2/m := by positivity
  have hexp : (1 + 2/m) ^ (m/2) = Real.exp (Real.log (1 + 2/m) * (m/2)) := by
    rw [← Real.rpow_def_of_pos hbase]
  rw [hexp]
  have : Real.log (1 + 2/m) * (m/2) < (2/m) * (m/2) := by
    apply mul_lt_mul_of_pos_right hlog (by positivity)
  have heq : (2/m) * (m/2) = 1 := by field_simp
  rw [heq] at this
  exact Real.exp_lt_exp.mpr this

-- Aux 2: For m > 0, e < (1 + 2/m)^((m+2)/2)
private lemma aux_e_lt_rpow (m : ℝ) (hm : 0 < m) :
    Real.exp 1 < (1 + 2/m) ^ ((m+2)/2) := by
  have h2m : 0 < 2/m := by positivity
  have hlog : 2 * (2/m) / (2/m + 2) < Real.log (1 + 2/m) :=
    Real.lt_log_one_add_of_pos h2m
  have hsimp : 2 * (2/m) / (2/m + 2) = 2 / (m + 1) := by
    field_simp
    ring
  rw [hsimp] at hlog
  have hbase : 0 < 1 + 2/m := by positivity
  have hexp : (1 + 2/m) ^ ((m+2)/2) = Real.exp (Real.log (1 + 2/m) * ((m+2)/2)) := by
    rw [← Real.rpow_def_of_pos hbase]
  rw [hexp]
  have hpos : 0 < (m+2)/2 := by linarith
  have h1 : 2 / (m + 1) * ((m+2)/2) < Real.log (1 + 2/m) * ((m+2)/2) :=
    mul_lt_mul_of_pos_right hlog hpos
  have hkey : 2 / (m + 1) * ((m+2)/2) = (m+2)/(m+1) := by
    field_simp
  rw [hkey] at h1
  have h2 : (1 : ℝ) < (m+2)/(m+1) := by
    rw [lt_div_iff (by linarith : (0:ℝ) < m + 1)]
    linarith
  have h3 : (1 : ℝ) < Real.log (1 + 2/m) * ((m+2)/2) := lt_trans h2 h1
  exact Real.exp_lt_exp.mpr h3

theorem putnam_1996_b2 (n : ℕ) (hn : n ≥ 1) :
    ((2 * (n : ℝ) - 1) / Real.exp 1) ^ ((2 * (n : ℝ) - 1) / 2) <
      ∏ k ∈ Finset.Icc 1 n, (2 * (k : ℝ) - 1) ∧
    (∏ k ∈ Finset.Icc 1 n, (2 * (k : ℝ) - 1)) <
      ((2 * (n : ℝ) + 1) / Real.exp 1) ^ ((2 * (n : ℝ) + 1) / 2) := by
  sorry
