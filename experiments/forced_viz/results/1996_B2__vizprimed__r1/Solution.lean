import Mathlib

open Real Finset

noncomputable def gB2 (x : ℝ) : ℝ := x / 2 * Real.log x - x / 2

/-- Convexity-type bounds for `g(x) = (x/2)(log x - 1)`, both reducing to
`log t ≤ t - 1`. -/
lemma gB2_bounds {a b : ℝ} (ha : 0 < a) (hb : 0 < b) :
    (b - a) / 2 * Real.log a ≤ gB2 b - gB2 a ∧
    gB2 b - gB2 a ≤ (b - a) / 2 * Real.log b := by
  have hba : Real.log (b / a) ≤ b / a - 1 := Real.log_le_sub_one_of_pos (by positivity)
  have hab : Real.log (a / b) ≤ a / b - 1 := Real.log_le_sub_one_of_pos (by positivity)
  rw [Real.log_div hb.ne' ha.ne'] at hba
  rw [Real.log_div ha.ne' hb.ne'] at hab
  have e1 : a * (Real.log b - Real.log a) ≤ b - a := by
    have h := mul_le_mul_of_nonneg_left hba ha.le
    have hr : a * (b / a - 1) = b - a := by field_simp
    nlinarith [h, hr]
  have e2 : b * (Real.log a - Real.log b) ≤ a - b := by
    have h := mul_le_mul_of_nonneg_left hab hb.le
    have hr : b * (a / b - 1) = a - b := by field_simp
    nlinarith [h, hr]
  unfold gB2
  constructor
  · nlinarith [e2]
  · nlinarith [e1]

theorem putnam_1996_b2 (n : ℕ) (hn : 0 < n) :
    ((2 * (n : ℝ) - 1) / Real.exp 1) ^ ((2 * (n : ℝ) - 1) / 2)
        < ∏ i ∈ Finset.range n, (2 * (i : ℝ) + 1) ∧
      (∏ i ∈ Finset.range n, (2 * (i : ℝ) + 1))
        < ((2 * (n : ℝ) + 1) / Real.exp 1) ^ ((2 * (n : ℝ) + 1) / 2) := by
  set P : ℕ → ℝ := fun m => ∏ i ∈ Finset.range m, (2 * (i : ℝ) + 1) with hP
  have hPpos : ∀ m, 0 < P m := by
    intro m
    apply Finset.prod_pos
    intro i _
    positivity
  have main : ∀ m : ℕ, 1 ≤ m →
      gB2 (2 * (m : ℝ) - 1) < Real.log (P m) ∧
      Real.log (P m) < gB2 (2 * (m : ℝ) + 1) := by
    intro m hm
    induction m, hm using Nat.le_induction with
    | base =>
      have hP1 : P 1 = 1 := by simp [hP]
      rw [hP1, Real.log_one]
      constructor
      · have hg : gB2 (2 * (1 : ℝ) - 1) = -(1 / 2) := by unfold gB2; norm_num
        rw [hg]; norm_num
      · have h3 : (1 : ℝ) < Real.log 3 := by
          rw [Real.lt_log_iff_exp_lt (by norm_num)]
          linarith [Real.exp_one_lt_d9]
        have hg : gB2 (2 * (1 : ℝ) + 1) = 3 / 2 * Real.log 3 - 3 / 2 := by
          unfold gB2; norm_num
        rw [hg]; nlinarith [h3]
    | succ k hk ih =>
      have hkpos : (1 : ℝ) ≤ (k : ℝ) := by exact_mod_cast hk
      have hPsucc : P (k + 1) = P k * (2 * (k : ℝ) + 1) := by
        simp [hP, Finset.prod_range_succ]
      have hfac : (0 : ℝ) < 2 * (k : ℝ) + 1 := by positivity
      have hlog : Real.log (P (k + 1))
          = Real.log (P k) + Real.log (2 * (k : ℝ) + 1) := by
        rw [hPsucc, Real.log_mul (hPpos k).ne' hfac.ne']
      have ha1 : (0 : ℝ) < 2 * (k : ℝ) - 1 := by linarith
      have ha2 : (0 : ℝ) < 2 * (k : ℝ) + 1 := hfac
      have ha3 : (0 : ℝ) < 2 * (k : ℝ) + 3 := by linarith
      have b1 := gB2_bounds ha2 ha3
      have b2 := gB2_bounds ha1 ha2
      have e1 : Real.log (2 * (k : ℝ) + 1)
          ≤ gB2 (2 * (k : ℝ) + 3) - gB2 (2 * (k : ℝ) + 1) := by
        nlinarith [b1.1]
      have e2 : gB2 (2 * (k : ℝ) + 1) - gB2 (2 * (k : ℝ) - 1)
          ≤ Real.log (2 * (k : ℝ) + 1) := by
        nlinarith [b2.2]
      obtain ⟨ihL, ihU⟩ := ih
      have c1 : 2 * ((k : ℝ) + 1) - 1 = 2 * (k : ℝ) + 1 := by ring
      have c2 : 2 * ((k : ℝ) + 1) + 1 = 2 * (k : ℝ) + 3 := by ring
      push_cast
      rw [c1, c2, hlog]
      exact ⟨by linarith [ihL, e2], by linarith [ihU, e1]⟩
  obtain ⟨hD, hU⟩ := main n hn
  have hnpos : (1 : ℝ) ≤ (n : ℝ) := by exact_mod_cast hn
  have hApos : (0 : ℝ) < 2 * (n : ℝ) - 1 := by linarith
  have hBpos : (0 : ℝ) < 2 * (n : ℝ) + 1 := by linarith
  have hLlog : Real.log (((2 * (n : ℝ) - 1) / Real.exp 1) ^ ((2 * (n : ℝ) - 1) / 2))
      = gB2 (2 * (n : ℝ) - 1) := by
    rw [Real.log_rpow (by positivity), Real.log_div hApos.ne' (Real.exp_pos 1).ne',
      Real.log_exp]
    unfold gB2; ring
  have hRlog : Real.log (((2 * (n : ℝ) + 1) / Real.exp 1) ^ ((2 * (n : ℝ) + 1) / 2))
      = gB2 (2 * (n : ℝ) + 1) := by
    rw [Real.log_rpow (by positivity), Real.log_div hBpos.ne' (Real.exp_pos 1).ne',
      Real.log_exp]
    unfold gB2; ring
  have hLexp : ((2 * (n : ℝ) - 1) / Real.exp 1) ^ ((2 * (n : ℝ) - 1) / 2)
      = Real.exp (gB2 (2 * (n : ℝ) - 1)) := by
    rw [← hLlog, Real.exp_log (by positivity)]
  have hRexp : ((2 * (n : ℝ) + 1) / Real.exp 1) ^ ((2 * (n : ℝ) + 1) / 2)
      = Real.exp (gB2 (2 * (n : ℝ) + 1)) := by
    rw [← hRlog, Real.exp_log (by positivity)]
  have hPexp : P n = Real.exp (Real.log (P n)) := (Real.exp_log (hPpos n)).symm
  constructor
  · rw [hLexp, hPexp]
    exact Real.exp_lt_exp.mpr hD
  · rw [hRexp, hPexp]
    exact Real.exp_lt_exp.mpr hU
