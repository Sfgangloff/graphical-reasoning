import Mathlib

open Real MeasureTheory intervalIntegral

noncomputable def putnam_1987_b1_solution : ℝ := 1

theorem putnam_1987_b1 :
    ∫ x in (2:ℝ)..4, Real.sqrt (Real.log (9 - x)) /
      (Real.sqrt (Real.log (9 - x)) + Real.sqrt (Real.log (x + 3)))
    = putnam_1987_b1_solution := by
  unfold putnam_1987_b1_solution
  set f : ℝ → ℝ := fun x => Real.sqrt (Real.log (9 - x)) /
      (Real.sqrt (Real.log (9 - x)) + Real.sqrt (Real.log (x + 3))) with hf_def
  -- Key fact: f(x) + f(6-x) = 1 for x ∈ [2,4]
  have hkey : ∀ x ∈ Set.Icc (2:ℝ) 4, f x + f (6 - x) = 1 := by
    intro x hx
    simp only [hf_def]
    have h1 : (9 : ℝ) - (6 - x) = x + 3 := by ring
    have h2 : (6 - x) + 3 = 9 - x := by ring
    rw [h1, h2]
    have hxlt : x ≤ 4 := hx.2
    have hxgt : 2 ≤ x := hx.1
    have hpos1 : Real.log (9 - x) > 0 := Real.log_pos (by linarith)
    have hpos2 : Real.log (x + 3) > 0 := Real.log_pos (by linarith)
    have ha : Real.sqrt (Real.log (9 - x)) > 0 := Real.sqrt_pos.mpr hpos1
    have hb : Real.sqrt (Real.log (x + 3)) > 0 := Real.sqrt_pos.mpr hpos2
    have hab : Real.sqrt (Real.log (9 - x)) + Real.sqrt (Real.log (x + 3)) > 0 := by linarith
    have hba : Real.sqrt (Real.log (x + 3)) + Real.sqrt (Real.log (9 - x)) > 0 := by linarith
    field_simp
    ring
  -- Continuity of f on [2,4]
  have hcont : ContinuousOn f (Set.Icc (2:ℝ) 4) := by
    simp only [hf_def]
    apply ContinuousOn.div
    · apply ContinuousOn.sqrt
      apply ContinuousOn.log
      · fun_prop
      · intro x hx
        have : x ≤ 4 := hx.2; linarith
    · apply ContinuousOn.add
      · apply ContinuousOn.sqrt
        apply ContinuousOn.log
        · fun_prop
        · intro x hx
          have : x ≤ 4 := hx.2; linarith
      · apply ContinuousOn.sqrt
        apply ContinuousOn.log
        · fun_prop
        · intro x hx
          have : 2 ≤ x := hx.1; linarith
    · intro x hx
      have hxlt : x ≤ 4 := hx.2
      have hxgt : 2 ≤ x := hx.1
      have hpos1 : Real.log (9 - x) > 0 := Real.log_pos (by linarith)
      have hpos2 : Real.log (x + 3) > 0 := Real.log_pos (by linarith)
      have ha : Real.sqrt (Real.log (9 - x)) > 0 := Real.sqrt_pos.mpr hpos1
      have hb : Real.sqrt (Real.log (x + 3)) > 0 := Real.sqrt_pos.mpr hpos2
      linarith
  have hint_f : IntervalIntegrable f MeasureTheory.volume 2 4 :=
    hcont.intervalIntegrable_of_Icc (by norm_num)
  -- Substitution: ∫₂⁴ f(6-x) dx = ∫₂⁴ f(x) dx
  have hsub : ∫ x in (2:ℝ)..4, f (6 - x) = ∫ x in (2:ℝ)..4, f x := by
    have h := intervalIntegral.integral_comp_sub_left f 6 (a := 2) (b := 4)
    simp only at h
    -- h : ∫ x in 2..4, f (6 - x) = ∫ x in (6-4)..(6-2), f x
    have h6 : (6:ℝ) - 4 = 2 := by norm_num
    have h7 : (6:ℝ) - 2 = 4 := by norm_num
    rw [h6, h7] at h
    exact h
  -- Continuity of g(x) = f(6-x) on [2,4]
  have hcont_g : ContinuousOn (fun x => f (6 - x)) (Set.Icc (2:ℝ) 4) := by
    apply ContinuousOn.comp hcont (by fun_prop)
    intro x hx
    refine ⟨?_, ?_⟩
    · have : x ≤ 4 := hx.2; linarith
    · have : 2 ≤ x := hx.1; linarith
  have hint_g : IntervalIntegrable (fun x => f (6 - x)) MeasureTheory.volume 2 4 :=
    hcont_g.intervalIntegrable_of_Icc (by norm_num)
  -- Combine: ∫₂⁴ (f(x) + f(6-x)) dx = ∫₂⁴ 1 dx = 2
  have hsum : ∫ x in (2:ℝ)..4, (f x + f (6 - x)) = 2 := by
    have heq : Set.EqOn (fun x => f x + f (6 - x)) (fun _ => (1:ℝ)) (Set.uIcc (2:ℝ) 4) := by
      intro x hx
      rw [Set.uIcc_of_le (by norm_num : (2:ℝ) ≤ 4)] at hx
      exact hkey x hx
    rw [intervalIntegral.integral_congr heq]
    simp
    norm_num
  -- Now: ∫₂⁴ f + ∫₂⁴ f(6-x) = 2, but ∫₂⁴ f(6-x) = ∫₂⁴ f, so 2 ∫₂⁴ f = 2
  have hsum2 : (∫ x in (2:ℝ)..4, f x) + (∫ x in (2:ℝ)..4, f (6 - x)) = 2 := by
    rw [← intervalIntegral.integral_add hint_f hint_g]
    exact hsum
  rw [hsub] at hsum2
  linarith
