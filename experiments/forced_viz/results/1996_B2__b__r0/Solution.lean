import Mathlib

open scoped BigOperators

noncomputable def P (n : ℕ) : ℝ := ∏ k ∈ Finset.range n, (2 * (k : ℝ) + 1)

/-- `Lf m = ((2m-1)/e)^((2m-1)/2)`, written via `exp`. -/
noncomputable def Lf (m : ℕ) : ℝ :=
  Real.exp (((2 * (m : ℝ) - 1) / 2) * (Real.log (2 * (m : ℝ) - 1) - 1))

lemma P_pos (n : ℕ) : 0 < P n := by
  unfold P
  apply Finset.prod_pos
  intro k _
  positivity

lemma P_succ (n : ℕ) : P (n + 1) = P n * (2 * (n : ℝ) + 1) := by
  unfold P
  rw [Finset.prod_range_succ]
  push_cast
  ring_nf

lemma cruxA (n : ℕ) (hn : 1 ≤ n) : Lf (n + 1) ≤ (2 * (n : ℝ) + 1) * Lf n := by
  have hx : (1 : ℝ) ≤ (n : ℝ) := by exact_mod_cast hn
  have h1 : (0 : ℝ) < 2 * (n : ℝ) - 1 := by linarith
  have h2 : (0 : ℝ) < 2 * (n : ℝ) + 1 := by linarith
  have eA : Lf (n + 1)
      = Real.exp (((2 * (n : ℝ) + 1) / 2) * (Real.log (2 * (n : ℝ) + 1) - 1)) := by
    unfold Lf
    have he : (2 * ((↑(n + 1)) : ℝ) - 1) = 2 * (n : ℝ) + 1 := by push_cast; ring
    rw [he]
  have eB : (2 * (n : ℝ) + 1) * Lf n
      = Real.exp (Real.log (2 * (n : ℝ) + 1)
          + ((2 * (n : ℝ) - 1) / 2) * (Real.log (2 * (n : ℝ) - 1) - 1)) := by
    unfold Lf
    rw [Real.exp_add, Real.exp_log h2]
  rw [eA, eB, Real.exp_le_exp]
  have hdiv : Real.log ((2 * (n : ℝ) + 1) / (2 * (n : ℝ) - 1))
      ≤ (2 * (n : ℝ) + 1) / (2 * (n : ℝ) - 1) - 1 :=
    Real.log_le_sub_one_of_pos (by positivity)
  rw [Real.log_div (ne_of_gt h2) (ne_of_gt h1)] at hdiv
  have hrw : (2 * (n : ℝ) + 1) / (2 * (n : ℝ) - 1) - 1 = 2 / (2 * (n : ℝ) - 1) := by
    field_simp
    ring
  rw [hrw] at hdiv
  have hcl : (Real.log (2 * (n : ℝ) + 1) - Real.log (2 * (n : ℝ) - 1)) * (2 * (n : ℝ) - 1)
      ≤ 2 := by
    rw [← le_div_iff₀ h1]
    exact hdiv
  nlinarith [hcl, h1, h2]

lemma cruxB (n : ℕ) (hn : 1 ≤ n) :
    (2 * (n : ℝ) + 1) * Lf (n + 1) ≤ Lf (n + 2) := by
  have hx : (1 : ℝ) ≤ (n : ℝ) := by exact_mod_cast hn
  have h2 : (0 : ℝ) < 2 * (n : ℝ) + 1 := by linarith
  have h3 : (0 : ℝ) < 2 * (n : ℝ) + 3 := by linarith
  have eA : Lf (n + 2)
      = Real.exp (((2 * (n : ℝ) + 3) / 2) * (Real.log (2 * (n : ℝ) + 3) - 1)) := by
    unfold Lf
    have he : (2 * ((↑(n + 2)) : ℝ) - 1) = 2 * (n : ℝ) + 3 := by push_cast; ring
    rw [he]
  have eB : (2 * (n : ℝ) + 1) * Lf (n + 1)
      = Real.exp (Real.log (2 * (n : ℝ) + 1)
          + ((2 * (n : ℝ) + 1) / 2) * (Real.log (2 * (n : ℝ) + 1) - 1)) := by
    unfold Lf
    have he : (2 * ((↑(n + 1)) : ℝ) - 1) = 2 * (n : ℝ) + 1 := by push_cast; ring
    rw [he, Real.exp_add, Real.exp_log h2]
  rw [eA, eB, Real.exp_le_exp]
  have hdiv : Real.log ((2 * (n : ℝ) + 1) / (2 * (n : ℝ) + 3))
      ≤ (2 * (n : ℝ) + 1) / (2 * (n : ℝ) + 3) - 1 :=
    Real.log_le_sub_one_of_pos (by positivity)
  rw [Real.log_div (ne_of_gt h2) (ne_of_gt h3)] at hdiv
  have hrw : (2 * (n : ℝ) + 1) / (2 * (n : ℝ) + 3) - 1 = -2 / (2 * (n : ℝ) + 3) := by
    field_simp
    ring
  rw [hrw] at hdiv
  have hcl : (Real.log (2 * (n : ℝ) + 1) - Real.log (2 * (n : ℝ) + 3)) * (2 * (n : ℝ) + 3)
      ≤ -2 := by
    rw [← le_div_iff₀ h3]
    exact hdiv
  nlinarith [hcl, h2, h3]

lemma left : ∀ n, 1 ≤ n → Lf n < P n := by
  intro n hn
  induction n, hn using Nat.le_induction with
  | base =>
      have hP : P 1 = 1 := by unfold P; simp
      have hL : Lf 1 = Real.exp (-(1 / 2 : ℝ)) := by
        unfold Lf
        norm_num [Real.log_one]
      rw [hP, hL]
      have hlt : Real.exp (-(1 / 2 : ℝ)) < Real.exp 0 := by
        apply Real.exp_lt_exp.mpr; norm_num
      rwa [Real.exp_zero] at hlt
  | succ k hk ih =>
      have hk2 : (0 : ℝ) < 2 * (k : ℝ) + 1 := by positivity
      have hA : Lf (k + 1) ≤ (2 * (k : ℝ) + 1) * Lf k := cruxA k hk
      have hmul : (2 * (k : ℝ) + 1) * Lf k < (2 * (k : ℝ) + 1) * P k :=
        mul_lt_mul_of_pos_left ih hk2
      rw [P_succ]
      calc Lf (k + 1) ≤ (2 * (k : ℝ) + 1) * Lf k := hA
        _ < (2 * (k : ℝ) + 1) * P k := hmul
        _ = P k * (2 * (k : ℝ) + 1) := by ring

lemma right : ∀ n, 1 ≤ n → P n < Lf (n + 1) := by
  intro n hn
  induction n, hn using Nat.le_induction with
  | base =>
      have hP : P 1 = 1 := by unfold P; simp
      have hLval : Lf 2 = Real.exp ((3 / 2 : ℝ) * (Real.log 3 - 1)) := by
        unfold Lf
        norm_num
      rw [hP, hLval]
      have he3 : Real.exp 1 < 3 := by
        have h := Real.exp_one_lt_d9
        norm_num at h ⊢
        linarith
      have hlog3 : (1 : ℝ) < Real.log 3 := by
        have h := Real.log_lt_log (Real.exp_pos 1) he3
        rwa [Real.log_exp] at h
      have hpos : (0 : ℝ) < (3 / 2 : ℝ) * (Real.log 3 - 1) := by nlinarith
      have hlt : Real.exp 0 < Real.exp ((3 / 2 : ℝ) * (Real.log 3 - 1)) :=
        Real.exp_lt_exp.mpr hpos
      rwa [Real.exp_zero] at hlt
  | succ k hk ih =>
      have hk2 : (0 : ℝ) < 2 * (k : ℝ) + 1 := by positivity
      have hB : (2 * (k : ℝ) + 1) * Lf (k + 1) ≤ Lf (k + 2) := cruxB k hk
      have hmul : P k * (2 * (k : ℝ) + 1) < Lf (k + 1) * (2 * (k : ℝ) + 1) :=
        mul_lt_mul_of_pos_right ih hk2
      rw [P_succ]
      calc P k * (2 * (k : ℝ) + 1)
          < Lf (k + 1) * (2 * (k : ℝ) + 1) := hmul
        _ = (2 * (k : ℝ) + 1) * Lf (k + 1) := by ring
        _ ≤ Lf (k + 2) := hB

lemma Lf_eq (m : ℕ) (hm : 1 ≤ m) :
    ((2 * (m : ℝ) - 1) / Real.exp 1) ^ ((2 * (m : ℝ) - 1) / 2) = Lf m := by
  have hx : (1 : ℝ) ≤ (m : ℝ) := by exact_mod_cast hm
  have hpos : (0 : ℝ) < 2 * (m : ℝ) - 1 := by linarith
  have hb : (0 : ℝ) < (2 * (m : ℝ) - 1) / Real.exp 1 := by positivity
  rw [Real.rpow_def_of_pos hb,
      Real.log_div (ne_of_gt hpos) (ne_of_gt (Real.exp_pos 1)), Real.log_exp]
  unfold Lf
  congr 1
  ring

theorem putnam_1996_b2 (n : ℕ) (hn : 0 < n) :
    ((2 * (n : ℝ) - 1) / Real.exp 1) ^ ((2 * (n : ℝ) - 1) / 2)
        < (∏ k ∈ Finset.range n, (2 * (k : ℝ) + 1))
    ∧ (∏ k ∈ Finset.range n, (2 * (k : ℝ) + 1))
        < ((2 * (n : ℝ) + 1) / Real.exp 1) ^ ((2 * (n : ℝ) + 1) / 2) := by
  have hn1 : 1 ≤ n := hn
  refine ⟨?_, ?_⟩
  · rw [Lf_eq n hn1]
    exact left n hn1
  · have hRHS : ((2 * (n : ℝ) + 1) / Real.exp 1) ^ ((2 * (n : ℝ) + 1) / 2)
        = Lf (n + 1) := by
      have h := Lf_eq (n + 1) (by omega)
      have he : (2 * ((↑(n + 1)) : ℝ) - 1) = 2 * (n : ℝ) + 1 := by push_cast; ring
      rw [he] at h
      exact h
    rw [hRHS]
    exact right n hn1
