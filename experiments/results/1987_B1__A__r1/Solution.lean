import Mathlib

open Real intervalIntegral MeasureTheory

noncomputable def putnam_1987_b1_solution : ℝ := 1

theorem putnam_1987_b1 :
    ∫ x in (2 : ℝ)..4, Real.sqrt (Real.log (9 - x)) /
      (Real.sqrt (Real.log (9 - x)) + Real.sqrt (Real.log (x + 3))) =
    putnam_1987_b1_solution := by
  unfold putnam_1987_b1_solution
  set h : ℝ → ℝ := fun x => Real.sqrt (Real.log (9 - x)) /
      (Real.sqrt (Real.log (9 - x)) + Real.sqrt (Real.log (x + 3))) with hh
  -- Substitution: ∫ h(x) dx = ∫ h(6-x) dx over [2,4]
  have hsub : ∫ x in (2:ℝ)..4, h x = ∫ x in (2:ℝ)..4, h (6 - x) := by
    conv_rhs => rw [intervalIntegral.integral_comp_sub_left h 6]
    norm_num
  -- Continuity of h on [2,4]
  have hcont : ContinuousOn h (Set.Icc (2:ℝ) 4) := by
    intro x hx
    obtain ⟨hx1, hx2⟩ := hx
    have h9x : (9:ℝ) - x ≠ 0 := by linarith
    have hx3 : x + 3 ≠ 0 := by linarith
    have hp1pos : Real.log (9 - x) > 0 := Real.log_pos (by linarith)
    have hp2pos : Real.log (x + 3) > 0 := Real.log_pos (by linarith)
    have hsqrt1pos : Real.sqrt (Real.log (9 - x)) > 0 := Real.sqrt_pos.mpr hp1pos
    have hsqrt2pos : Real.sqrt (Real.log (x + 3)) > 0 := Real.sqrt_pos.mpr hp2pos
    have hc1 : ContinuousAt (fun y : ℝ => 9 - y) x :=
      (continuous_const.sub continuous_id).continuousAt
    have hc2 : ContinuousAt (fun y : ℝ => y + 3) x :=
      (continuous_id.add continuous_const).continuousAt
    have hl1 : ContinuousAt (fun y : ℝ => Real.log (9 - y)) x := hc1.log h9x
    have hl2 : ContinuousAt (fun y : ℝ => Real.log (y + 3)) x := hc2.log hx3
    have hf1 : ContinuousAt (fun y : ℝ => Real.sqrt (Real.log (9 - y))) x := hl1.sqrt
    have hf2 : ContinuousAt (fun y : ℝ => Real.sqrt (Real.log (y + 3))) x := hl2.sqrt
    apply ContinuousAt.continuousWithinAt
    exact hf1.div (hf1.add hf2) (by linarith)
  -- h(6-x) is also continuous on [2,4]
  have hcont' : ContinuousOn (fun x => h (6 - x)) (Set.Icc (2:ℝ) 4) := by
    have hsub_cont : ContinuousOn (fun x => (6:ℝ) - x) (Set.Icc (2:ℝ) 4) :=
      (continuous_const.sub continuous_id).continuousOn
    apply hcont.comp hsub_cont
    intro x ⟨hx1, hx2⟩
    constructor <;> linarith
  -- Both integrable
  have hint : IntervalIntegrable h MeasureTheory.volume 2 4 :=
    hcont.intervalIntegrable_of_Icc (by norm_num)
  have hint' : IntervalIntegrable (fun x => h (6 - x)) MeasureTheory.volume 2 4 :=
    hcont'.intervalIntegrable_of_Icc (by norm_num)
  -- Sum of integrals equals integral of sum
  have hsum : (∫ x in (2:ℝ)..4, h x) + (∫ x in (2:ℝ)..4, h (6 - x)) =
              ∫ x in (2:ℝ)..4, (h x + h (6 - x)) := by
    rw [← intervalIntegral.integral_add hint hint']
  -- Key identity: h(x) + h(6-x) = 1 for x in [2,4]
  have hkey : ∀ x ∈ Set.Icc (2:ℝ) 4, h x + h (6 - x) = 1 := by
    intro x ⟨hx1, hx2⟩
    show Real.sqrt (Real.log (9 - x)) / (Real.sqrt (Real.log (9 - x)) + Real.sqrt (Real.log (x + 3)))
       + Real.sqrt (Real.log (9 - (6 - x))) / (Real.sqrt (Real.log (9 - (6 - x))) + Real.sqrt (Real.log ((6 - x) + 3)))
       = 1
    have e1 : (9 : ℝ) - (6 - x) = x + 3 := by ring
    have e2 : (6 - x) + 3 = 9 - x := by ring
    rw [e1, e2]
    have hp1 : Real.sqrt (Real.log (9 - x)) > 0 := by
      apply Real.sqrt_pos.mpr; apply Real.log_pos; linarith
    have hp2 : Real.sqrt (Real.log (x + 3)) > 0 := by
      apply Real.sqrt_pos.mpr; apply Real.log_pos; linarith
    have hpos : Real.sqrt (Real.log (9 - x)) + Real.sqrt (Real.log (x + 3)) > 0 := by linarith
    field_simp
    ring
  -- Therefore ∫ (h(x) + h(6-x)) dx = ∫ 1 dx = 2
  have hint1 : ∫ x in (2:ℝ)..4, (h x + h (6 - x)) = ∫ x in (2:ℝ)..4, (1 : ℝ) := by
    apply intervalIntegral.integral_congr
    intro x hx
    rw [Set.uIcc_of_le (by norm_num : (2:ℝ) ≤ 4)] at hx
    exact hkey x hx
  have hone : ∫ x in (2:ℝ)..4, (1 : ℝ) = 2 := by
    rw [intervalIntegral.integral_const]; norm_num
  -- Combine
  have h2I : 2 * (∫ x in (2:ℝ)..4, h x) = 2 := by
    have step1 := hsum
    rw [← hsub] at step1
    have step2 : (∫ x in (2:ℝ)..4, h x) + (∫ x in (2:ℝ)..4, h x) = 2 := by
      rw [step1, hint1, hone]
    linarith
  linarith
