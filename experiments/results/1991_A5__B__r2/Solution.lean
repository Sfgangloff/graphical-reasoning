import Mathlib

open MeasureTheory intervalIntegral Real Set

noncomputable def putnam_1991_a5_solution : ℝ := 1/3

theorem putnam_1991_a5 :
    IsGreatest {v : ℝ | ∃ y ∈ Set.Icc (0:ℝ) 1,
        v = ∫ x in (0:ℝ)..y, Real.sqrt (x^4 + (y - y^2)^2)}
      putnam_1991_a5_solution := by
  constructor
  · -- 1/3 is in the set: take y = 1
    refine ⟨1, ⟨zero_le_one, le_refl 1⟩, ?_⟩
    have h : ∀ x ∈ uIcc (0:ℝ) 1, Real.sqrt (x^4 + (1 - 1^2)^2) = x^2 := by
      intro x _
      have : (1:ℝ) - 1^2 = 0 := by ring
      rw [this]
      simp
      rw [show (x:ℝ)^4 = (x^2)^2 by ring]
      exact Real.sqrt_sq (sq_nonneg x)
    rw [intervalIntegral.integral_congr h]
    rw [integral_pow]
    simp [putnam_1991_a5_solution]
    norm_num
  · -- upper bound
    rintro v ⟨y, ⟨hy0, hy1⟩, hv⟩
    rw [hv]
    have hcy : 0 ≤ y - y^2 := by nlinarith
    have hcont : Continuous fun x : ℝ => Real.sqrt (x^4 + (y - y^2)^2) := by
      apply Real.continuous_sqrt.comp
      continuity
    have hcont' : Continuous fun x : ℝ => x^2 + (y - y^2) := by continuity
    have hint1 : IntervalIntegrable (fun x => Real.sqrt (x^4 + (y - y^2)^2)) MeasureTheory.volume 0 y :=
      hcont.intervalIntegrable 0 y
    have hint2 : IntervalIntegrable (fun x : ℝ => x^2 + (y - y^2)) MeasureTheory.volume 0 y :=
      hcont'.intervalIntegrable 0 y
    have hint_pow : IntervalIntegrable (fun x : ℝ => x^2) MeasureTheory.volume 0 y :=
      (continuous_pow 2).intervalIntegrable 0 y
    have hint_const : IntervalIntegrable (fun _ : ℝ => y - y^2) MeasureTheory.volume 0 y :=
      intervalIntegral.intervalIntegrable_const
    have hbound : ∫ x in (0:ℝ)..y, Real.sqrt (x^4 + (y - y^2)^2) ≤
                   ∫ x in (0:ℝ)..y, (x^2 + (y - y^2)) := by
      apply intervalIntegral.integral_mono_on hy0 hint1 hint2
      intro x hx
      have hx0 : 0 ≤ x := hx.1
      have hsum_nn : 0 ≤ x^2 + (y - y^2) := by nlinarith [sq_nonneg x]
      have heq : x^2 + (y - y^2) = Real.sqrt ((x^2 + (y - y^2))^2) := by
        rw [Real.sqrt_sq hsum_nn]
      rw [heq]
      apply Real.sqrt_le_sqrt
      nlinarith [sq_nonneg x, sq_nonneg (y - y^2), mul_nonneg (sq_nonneg x) hcy]
    have hrhs : ∫ x in (0:ℝ)..y, (x^2 + (y - y^2)) = y^3/3 + (y - y^2) * y := by
      rw [intervalIntegral.integral_add hint_pow hint_const]
      rw [integral_pow, intervalIntegral.integral_const]
      ring
    have hpoly : y^3/3 + (y - y^2) * y ≤ 1/3 := by
      nlinarith [sq_nonneg (y - 1), sq_nonneg y, hy0, hy1]
    calc ∫ x in (0:ℝ)..y, Real.sqrt (x^4 + (y - y^2)^2)
        ≤ ∫ x in (0:ℝ)..y, (x^2 + (y - y^2)) := hbound
      _ = y^3/3 + (y - y^2) * y := hrhs
      _ ≤ 1/3 := hpoly
      _ = putnam_1991_a5_solution := by simp [putnam_1991_a5_solution]
