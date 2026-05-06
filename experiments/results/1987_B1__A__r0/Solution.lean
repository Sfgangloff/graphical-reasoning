import Mathlib

open Real intervalIntegral MeasureTheory

noncomputable def putnam_1987_b1_solution : ℝ := 1

theorem putnam_1987_b1 :
    ∫ x in (2 : ℝ)..4,
      Real.sqrt (Real.log (9 - x)) /
        (Real.sqrt (Real.log (9 - x)) + Real.sqrt (Real.log (x + 3)))
      = putnam_1987_b1_solution := by
  -- Let f be the integrand
  set f : ℝ → ℝ := fun x =>
    Real.sqrt (Real.log (9 - x)) /
      (Real.sqrt (Real.log (9 - x)) + Real.sqrt (Real.log (x + 3))) with hf_def
  show ∫ x in (2:ℝ)..4, f x = 1
  -- denominator is positive on [2,4]
  have hpos : ∀ x, 2 ≤ x → x ≤ 4 →
      Real.sqrt (Real.log (9 - x)) + Real.sqrt (Real.log (x + 3)) > 0 := by
    intro x hx1 hx2
    have h9 : (5 : ℝ) ≤ 9 - x := by linarith
    have h5pos : (0 : ℝ) < 5 := by norm_num
    have hl9 : Real.log 5 ≤ Real.log (9 - x) := Real.log_le_log h5pos h9
    have h5log : 0 < Real.log 5 := Real.log_pos (by norm_num)
    have hl9pos : 0 < Real.log (9 - x) := lt_of_lt_of_le h5log hl9
    have hs9 : 0 < Real.sqrt (Real.log (9 - x)) := Real.sqrt_pos.mpr hl9pos
    have hs3 : 0 ≤ Real.sqrt (Real.log (x + 3)) := Real.sqrt_nonneg _
    linarith
  -- substitution: ∫ x in 2..4, f(6-x) = ∫ x in 2..4, f(x)
  have hsub : ∫ x in (2:ℝ)..4, f (6 - x) = ∫ x in (2:ℝ)..4, f x := by
    have h : ∫ x in (2:ℝ)..4, f (6 - x) = ∫ x in (6 - 4)..(6 - 2), f x :=
      intervalIntegral.integral_comp_sub_left (a := 2) (b := 4) f 6
    rw [h]; norm_num
  -- pointwise sum f(x) + f(6 - x) = 1 on (2, 4)
  have hsum : ∀ x, 2 ≤ x → x ≤ 4 → f x + f (6 - x) = 1 := by
    intro x hx1 hx2
    have hd := hpos x hx1 hx2
    have hd' : Real.sqrt (Real.log (x + 3)) + Real.sqrt (Real.log (9 - x)) > 0 := by linarith
    simp only [f, hf_def]
    have h1 : (9 : ℝ) - (6 - x) = x + 3 := by ring
    have h2 : (6 - x) + 3 = 9 - x := by ring
    rw [h1, h2]
    set a := Real.sqrt (Real.log (9 - x)) with ha
    set b := Real.sqrt (Real.log (x + 3)) with hb
    have hab : a + b > 0 := hd
    have hba : b + a > 0 := hd'
    field_simp
    ring
  -- continuity of f on [2,4]
  have hcont : ContinuousOn f (Set.Icc (2:ℝ) 4) := by
    apply ContinuousOn.div
    · refine Real.continuous_sqrt.comp_continuousOn ?_
      refine ContinuousOn.log ?_ ?_
      · exact (continuous_const.sub continuous_id).continuousOn
      · intro x hx
        rcases hx with ⟨hx1, hx2⟩
        have : (5 : ℝ) ≤ 9 - x := by linarith
        linarith
    · apply ContinuousOn.add
      · refine Real.continuous_sqrt.comp_continuousOn ?_
        refine ContinuousOn.log ?_ ?_
        · exact (continuous_const.sub continuous_id).continuousOn
        · intro x hx
          rcases hx with ⟨hx1, hx2⟩
          have : (5 : ℝ) ≤ 9 - x := by linarith
          linarith
      · refine Real.continuous_sqrt.comp_continuousOn ?_
        refine ContinuousOn.log ?_ ?_
        · exact (continuous_id.add continuous_const).continuousOn
        · intro x hx
          rcases hx with ⟨hx1, hx2⟩
          have : (5 : ℝ) ≤ x + 3 := by linarith
          linarith
    · intro x hx
      rcases hx with ⟨hx1, hx2⟩
      exact ne_of_gt (hpos x hx1 hx2)
  have hint : IntervalIntegrable f MeasureTheory.volume 2 4 :=
    hcont.intervalIntegrable_of_Icc (by norm_num)
  -- continuity of x ↦ f(6 - x) on [2,4]
  have hcont' : ContinuousOn (fun x => f (6 - x)) (Set.Icc (2:ℝ) 4) := by
    apply hcont.comp ((continuous_const.sub continuous_id).continuousOn)
    intro x hx
    rcases hx with ⟨hx1, hx2⟩
    refine ⟨?_, ?_⟩ <;> simp <;> linarith
  have hint' : IntervalIntegrable (fun x => f (6 - x)) MeasureTheory.volume 2 4 :=
    hcont'.intervalIntegrable_of_Icc (by norm_num)
  -- 2I = 2
  have hadd : ∫ x in (2:ℝ)..4, (f x + f (6 - x)) =
      (∫ x in (2:ℝ)..4, f x) + (∫ x in (2:ℝ)..4, f (6 - x)) :=
    intervalIntegral.integral_add hint hint'
  have hone : ∀ x ∈ Set.uIcc (2:ℝ) 4, f x + f (6 - x) = 1 := by
    intro x hx
    rw [Set.uIcc_of_le (by norm_num : (2:ℝ) ≤ 4)] at hx
    exact hsum x hx.1 hx.2
  have hone_int : ∫ x in (2:ℝ)..4, (f x + f (6 - x)) = ∫ x in (2:ℝ)..4, (1:ℝ) :=
    intervalIntegral.integral_congr hone
  have hr : ∫ x in (2:ℝ)..4, (1:ℝ) = 2 := by
    simp [intervalIntegral.integral_const]; norm_num
  -- combine
  have key : (∫ x in (2:ℝ)..4, f x) + (∫ x in (2:ℝ)..4, f x) = 2 := by
    calc (∫ x in (2:ℝ)..4, f x) + (∫ x in (2:ℝ)..4, f x)
        = (∫ x in (2:ℝ)..4, f x) + (∫ x in (2:ℝ)..4, f (6 - x)) := by rw [hsub]
      _ = ∫ x in (2:ℝ)..4, (f x + f (6 - x)) := by rw [hadd]
      _ = ∫ x in (2:ℝ)..4, (1:ℝ) := hone_int
      _ = 2 := hr
  linarith
