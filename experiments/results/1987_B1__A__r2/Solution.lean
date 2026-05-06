import Mathlib

open Real intervalIntegral MeasureTheory

noncomputable def putnam_1987_b1_solution : ℝ := 1

theorem putnam_1987_b1 :
    ∫ x in (2:ℝ)..4, Real.sqrt (Real.log (9 - x)) /
      (Real.sqrt (Real.log (9 - x)) + Real.sqrt (Real.log (x + 3))) =
    putnam_1987_b1_solution := by
  unfold putnam_1987_b1_solution
  set f : ℝ → ℝ := fun x => Real.sqrt (Real.log (9 - x)) /
      (Real.sqrt (Real.log (9 - x)) + Real.sqrt (Real.log (x + 3))) with hf
  -- Pointwise positivity facts on [2,4]
  have hlog9 : ∀ x ∈ Set.Icc (2:ℝ) 4, Real.log (9 - x) > 0 := by
    intro x hx
    apply Real.log_pos
    linarith [hx.1, hx.2]
  have hlog3 : ∀ x ∈ Set.Icc (2:ℝ) 4, Real.log (x + 3) > 0 := by
    intro x hx
    apply Real.log_pos
    linarith [hx.1, hx.2]
  have hsq9 : ∀ x ∈ Set.Icc (2:ℝ) 4, Real.sqrt (Real.log (9 - x)) > 0 := by
    intro x hx; exact Real.sqrt_pos.mpr (hlog9 x hx)
  have hsq3 : ∀ x ∈ Set.Icc (2:ℝ) 4, Real.sqrt (Real.log (x + 3)) > 0 := by
    intro x hx; exact Real.sqrt_pos.mpr (hlog3 x hx)
  have hden : ∀ x ∈ Set.Icc (2:ℝ) 4,
      Real.sqrt (Real.log (9 - x)) + Real.sqrt (Real.log (x + 3)) > 0 := by
    intro x hx
    linarith [hsq9 x hx, hsq3 x hx]
  -- Continuity on [2,4]
  have hcont9 : ContinuousOn (fun x : ℝ => Real.sqrt (Real.log (9 - x))) (Set.Icc (2:ℝ) 4) := by
    apply Real.continuous_sqrt.comp_continuousOn
    apply ContinuousOn.log
    · exact (continuous_const.sub continuous_id).continuousOn
    · intro x hx
      have h1 : (9:ℝ) - x > 0 := by linarith [hx.2]
      linarith
  have hcont3 : ContinuousOn (fun x : ℝ => Real.sqrt (Real.log (x + 3))) (Set.Icc (2:ℝ) 4) := by
    apply Real.continuous_sqrt.comp_continuousOn
    apply ContinuousOn.log
    · exact (continuous_id.add continuous_const).continuousOn
    · intro x hx
      have h1 : x + 3 > 0 := by linarith [hx.1]
      linarith
  have hcont : ContinuousOn f (Set.Icc (2:ℝ) 4) := by
    apply ContinuousOn.div hcont9 (hcont9.add hcont3)
    intro x hx
    exact ne_of_gt (hden x hx)
  -- Continuity of x ↦ f (6 - x) on [2, 4]
  have hcont' : ContinuousOn (fun x => f (6 - x)) (Set.Icc (2:ℝ) 4) := by
    have hmap : Set.MapsTo (fun x : ℝ => 6 - x) (Set.Icc (2:ℝ) 4) (Set.Icc (2:ℝ) 4) := by
      intro x hx
      refine ⟨by linarith [hx.2], by linarith [hx.1]⟩
    exact hcont.comp (continuous_const.sub continuous_id).continuousOn hmap
  -- Substitution: ∫ x in 2..4, f (6 - x) = ∫ x in 2..4, f x
  have hsub : ∫ x in (2:ℝ)..4, f (6 - x) = ∫ x in (2:ℝ)..4, f x := by
    have h24 : ∫ x in (2:ℝ)..4, f (6 - x) = ∫ x in (6-4:ℝ)..(6-2), f x :=
      intervalIntegral.integral_comp_sub_left (a := 2) (b := 4) f 6
    rw [h24]
    norm_num
  -- f x + f (6 - x) = 1 on [2,4]
  have hsum : ∀ x ∈ Set.Icc (2:ℝ) 4, f x + f (6 - x) = 1 := by
    intro x hx
    simp only [hf]
    have h9x : (9 : ℝ) - (6 - x) = x + 3 := by ring
    have hx3 : (6 - x) + 3 = 9 - x := by ring
    rw [h9x, hx3]
    have hd : Real.sqrt (Real.log (9 - x)) + Real.sqrt (Real.log (x + 3)) ≠ 0 :=
      ne_of_gt (hden x hx)
    rw [show (Real.sqrt (Real.log (x + 3)) + Real.sqrt (Real.log (9 - x))) =
        (Real.sqrt (Real.log (9 - x)) + Real.sqrt (Real.log (x + 3))) from add_comm _ _]
    rw [← add_div]
    exact div_self hd
  -- Integrability on [2,4]
  have hint_f : IntervalIntegrable f MeasureTheory.volume 2 4 :=
    hcont.intervalIntegrable_of_Icc (by norm_num)
  have hint_f' : IntervalIntegrable (fun x => f (6 - x)) MeasureTheory.volume 2 4 :=
    hcont'.intervalIntegrable_of_Icc (by norm_num)
  -- Twice the integral equals 2
  have h2I : (∫ x in (2:ℝ)..4, f x) + (∫ x in (2:ℝ)..4, f (6 - x)) = 2 := by
    rw [← intervalIntegral.integral_add hint_f hint_f']
    have : ∫ x in (2:ℝ)..4, (f x + f (6 - x)) = ∫ _ in (2:ℝ)..4, (1:ℝ) := by
      apply intervalIntegral.integral_congr
      intro x hx
      have hxIcc : x ∈ Set.Icc (2:ℝ) 4 := by
        rw [Set.uIcc_of_le (by norm_num : (2:ℝ) ≤ 4)] at hx
        exact hx
      exact hsum x hxIcc
    rw [this]
    simp; norm_num
  rw [hsub] at h2I
  linarith
