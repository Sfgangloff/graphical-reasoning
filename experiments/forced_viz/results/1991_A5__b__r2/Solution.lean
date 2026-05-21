import Mathlib

open scoped Real

noncomputable def putnam_1991_a5_solution : ℝ := 1 / 3

theorem putnam_1991_a5 :
    IsGreatest
      {z : ℝ | ∃ y ∈ Set.Icc (0 : ℝ) 1,
        z = ∫ x in (0 : ℝ)..y, Real.sqrt (x ^ 4 + (y - y ^ 2) ^ 2)}
      putnam_1991_a5_solution := by
  constructor
  · -- membership: y = 1 attains the value 1/3
    refine ⟨1, ⟨by norm_num, by norm_num⟩, ?_⟩
    have e : (fun x : ℝ => Real.sqrt (x ^ 4 + ((1 : ℝ) - 1 ^ 2) ^ 2))
        = fun x : ℝ => x ^ 2 := by
      funext x
      have h0 : ((1 : ℝ) - 1 ^ 2) ^ 2 = 0 := by norm_num
      rw [h0, add_zero, show x ^ 4 = (x ^ 2) ^ 2 by ring, Real.sqrt_sq (sq_nonneg x)]
    rw [putnam_1991_a5_solution, e, integral_pow]
    norm_num
  · -- upper bound: every value is ≤ 1/3
    rintro z ⟨y, ⟨hy0, hy1⟩, rfl⟩
    have hc : (0 : ℝ) ≤ y - y ^ 2 := by nlinarith
    have hbound : ∀ x : ℝ,
        Real.sqrt (x ^ 4 + (y - y ^ 2) ^ 2) ≤ x ^ 2 + (y - y ^ 2) := by
      intro x
      have h1 : x ^ 4 + (y - y ^ 2) ^ 2 ≤ (x ^ 2 + (y - y ^ 2)) ^ 2 := by
        nlinarith [sq_nonneg x, hc]
      calc Real.sqrt (x ^ 4 + (y - y ^ 2) ^ 2)
          ≤ Real.sqrt ((x ^ 2 + (y - y ^ 2)) ^ 2) := Real.sqrt_le_sqrt h1
        _ = x ^ 2 + (y - y ^ 2) := Real.sqrt_sq (by positivity)
    have hint1 : IntervalIntegrable
        (fun x => Real.sqrt (x ^ 4 + (y - y ^ 2) ^ 2)) MeasureTheory.volume 0 y :=
      (by fun_prop : Continuous fun x => Real.sqrt (x ^ 4 + (y - y ^ 2) ^ 2)).intervalIntegrable 0 y
    have hint2 : IntervalIntegrable
        (fun x => x ^ 2 + (y - y ^ 2)) MeasureTheory.volume 0 y :=
      (by fun_prop : Continuous fun x : ℝ => x ^ 2 + (y - y ^ 2)).intervalIntegrable 0 y
    have hintx2 : IntervalIntegrable (fun x : ℝ => x ^ 2) MeasureTheory.volume 0 y :=
      (by fun_prop : Continuous fun x : ℝ => x ^ 2).intervalIntegrable 0 y
    have hintc : IntervalIntegrable (fun _ : ℝ => y - y ^ 2) MeasureTheory.volume 0 y :=
      (by fun_prop : Continuous fun _ : ℝ => y - y ^ 2).intervalIntegrable 0 y
    have hmono : (∫ x in (0 : ℝ)..y, Real.sqrt (x ^ 4 + (y - y ^ 2) ^ 2))
        ≤ ∫ x in (0 : ℝ)..y, (x ^ 2 + (y - y ^ 2)) := by
      apply intervalIntegral.integral_mono_on hy0 hint1 hint2
      intro x _
      exact hbound x
    have heval : (∫ x in (0 : ℝ)..y, (x ^ 2 + (y - y ^ 2)))
        = y ^ 3 / 3 + y * (y - y ^ 2) := by
      rw [intervalIntegral.integral_add hintx2 hintc, integral_pow,
        intervalIntegral.integral_const]
      simp
      ring
    rw [putnam_1991_a5_solution]
    calc (∫ x in (0 : ℝ)..y, Real.sqrt (x ^ 4 + (y - y ^ 2) ^ 2))
        ≤ ∫ x in (0 : ℝ)..y, (x ^ 2 + (y - y ^ 2)) := hmono
      _ = y ^ 3 / 3 + y * (y - y ^ 2) := heval
      _ ≤ 1 / 3 := by nlinarith [sq_nonneg (y - 1), hy0, hy1]
