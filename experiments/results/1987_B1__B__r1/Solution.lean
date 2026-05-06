import Mathlib

open Real MeasureTheory intervalIntegral

noncomputable def putnam_1987_b1_solution : ℝ := 1

theorem putnam_1987_b1 :
    ∫ x in (2:ℝ)..4, Real.sqrt (Real.log (9 - x)) /
      (Real.sqrt (Real.log (9 - x)) + Real.sqrt (Real.log (x + 3)))
        = putnam_1987_b1_solution := by
  unfold putnam_1987_b1_solution
  set f : ℝ → ℝ := fun x =>
    Real.sqrt (Real.log (9 - x)) /
      (Real.sqrt (Real.log (9 - x)) + Real.sqrt (Real.log (x + 3))) with hfdef
  set g : ℝ → ℝ := fun x =>
    Real.sqrt (Real.log (x + 3)) /
      (Real.sqrt (Real.log (9 - x)) + Real.sqrt (Real.log (x + 3))) with hgdef
  -- (1) f and g are related by x ↦ 6 - x
  have hfg : ∀ x : ℝ, f x = g (6 - x) := by
    intro x
    simp only [hfdef, hgdef]
    have e1 : (9 : ℝ) - (6 - x) = x + 3 := by ring
    have e2 : (6 - x) + 3 = 9 - x := by ring
    rw [e1, e2, add_comm]
  -- (2) ∫ f = ∫ g via the substitution u = 6 - x
  have hsub : (∫ x in (2:ℝ)..4, f x) = (∫ x in (2:ℝ)..4, g x) := by
    have step1 : (∫ x in (2:ℝ)..4, f x) = (∫ x in (2:ℝ)..4, g (6 - x)) := by
      apply intervalIntegral.integral_congr
      intro x _
      exact hfg x
    rw [step1]
    have h := intervalIntegral.integral_comp_sub_left (a := (2:ℝ)) (b := (4:ℝ)) g 6
    have e1 : (6:ℝ) - 4 = 2 := by norm_num
    have e2 : (6:ℝ) - 2 = 4 := by norm_num
    rw [h, e1, e2]
  -- (3) Denominator positive on [2, 4]
  have hdenom : ∀ x : ℝ, x ∈ Set.uIcc (2:ℝ) 4 →
      Real.sqrt (Real.log (9 - x)) + Real.sqrt (Real.log (x + 3)) > 0 := by
    intro x hx
    rw [Set.uIcc_of_le (by norm_num : (2:ℝ) ≤ 4)] at hx
    have h1 : (9 - x : ℝ) > 1 := by linarith [hx.2]
    have h2 : (x + 3 : ℝ) > 1 := by linarith [hx.1]
    have hl1 : Real.log (9 - x) > 0 := Real.log_pos h1
    have hl2 : Real.log (x + 3) > 0 := Real.log_pos h2
    have hs1 : Real.sqrt (Real.log (9 - x)) > 0 := Real.sqrt_pos.mpr hl1
    have hs2 : Real.sqrt (Real.log (x + 3)) > 0 := Real.sqrt_pos.mpr hl2
    linarith
  -- (4) f + g = 1 on [2,4]
  have hsum : ∀ x : ℝ, x ∈ Set.uIcc (2:ℝ) 4 → f x + g x = 1 := by
    intro x hx
    have hd := hdenom x hx
    simp only [hfdef, hgdef]
    field_simp
  -- (5) Continuity ⇒ integrability
  have h9mx_pos : ∀ x ∈ Set.uIcc (2:ℝ) 4, (9 - x : ℝ) > 1 := by
    intro x hx
    rw [Set.uIcc_of_le (by norm_num : (2:ℝ) ≤ 4)] at hx
    linarith [hx.2]
  have hxp3_pos : ∀ x ∈ Set.uIcc (2:ℝ) 4, (x + 3 : ℝ) > 1 := by
    intro x hx
    rw [Set.uIcc_of_le (by norm_num : (2:ℝ) ≤ 4)] at hx
    linarith [hx.1]
  have hf_cont : ContinuousOn f (Set.uIcc (2:ℝ) 4) := by
    simp only [hfdef]
    apply ContinuousOn.div
    · apply Real.continuous_sqrt.continuousOn.comp
      · apply ContinuousOn.log
        · exact (continuous_const.sub continuous_id).continuousOn
        · intro x hx; have := h9mx_pos x hx; linarith
      · intro x _; exact Set.mem_univ _
    · apply ContinuousOn.add
      · apply Real.continuous_sqrt.continuousOn.comp
        · apply ContinuousOn.log
          · exact (continuous_const.sub continuous_id).continuousOn
          · intro x hx; have := h9mx_pos x hx; linarith
        · intro x _; exact Set.mem_univ _
      · apply Real.continuous_sqrt.continuousOn.comp
        · apply ContinuousOn.log
          · exact (continuous_id.add continuous_const).continuousOn
          · intro x hx; have := hxp3_pos x hx; linarith
        · intro x _; exact Set.mem_univ _
    · intro x hx
      have := hdenom x hx
      linarith
  have hg_cont : ContinuousOn g (Set.uIcc (2:ℝ) 4) := by
    simp only [hgdef]
    apply ContinuousOn.div
    · apply Real.continuous_sqrt.continuousOn.comp
      · apply ContinuousOn.log
        · exact (continuous_id.add continuous_const).continuousOn
        · intro x hx; have := hxp3_pos x hx; linarith
      · intro x _; exact Set.mem_univ _
    · apply ContinuousOn.add
      · apply Real.continuous_sqrt.continuousOn.comp
        · apply ContinuousOn.log
          · exact (continuous_const.sub continuous_id).continuousOn
          · intro x hx; have := h9mx_pos x hx; linarith
        · intro x _; exact Set.mem_univ _
      · apply Real.continuous_sqrt.continuousOn.comp
        · apply ContinuousOn.log
          · exact (continuous_id.add continuous_const).continuousOn
          · intro x hx; have := hxp3_pos x hx; linarith
        · intro x _; exact Set.mem_univ _
    · intro x hx
      have := hdenom x hx
      linarith
  have hf_int : IntervalIntegrable f MeasureTheory.volume 2 4 :=
    hf_cont.intervalIntegrable
  have hg_int : IntervalIntegrable g MeasureTheory.volume 2 4 :=
    hg_cont.intervalIntegrable
  -- (6) ∫ (f + g) = ∫ 1 = 2
  have hsum_int : (∫ x in (2:ℝ)..4, f x) + (∫ x in (2:ℝ)..4, g x) = 2 := by
    rw [← intervalIntegral.integral_add hf_int hg_int]
    have heq : (∫ x in (2:ℝ)..4, f x + g x) = (∫ _ in (2:ℝ)..4, (1 : ℝ)) := by
      apply intervalIntegral.integral_congr
      exact hsum
    rw [heq, intervalIntegral.integral_const]
    norm_num
  -- (7) Combine
  linarith [hsub, hsum_int]
