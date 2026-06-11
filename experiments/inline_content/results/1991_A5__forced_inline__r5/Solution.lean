import Mathlib

open intervalIntegral

noncomputable abbrev putnam_1991_a5_solution : ℝ := 1 / 3

theorem putnam_1991_a5 :
    IsGreatest
      {t : ℝ | ∃ y ∈ Set.Icc (0 : ℝ) 1,
        ∫ x in (0 : ℝ)..y, Real.sqrt (x ^ 4 + (y - y ^ 2) ^ 2) = t}
      putnam_1991_a5_solution := by
  constructor
  · -- membership: y = 1 attains the value 1/3
    refine ⟨1, ?_, ?_⟩
    · constructor <;> norm_num
    · have h : (fun x : ℝ => Real.sqrt (x ^ 4 + ((1 : ℝ) - 1 ^ 2) ^ 2))
          = fun x : ℝ => x ^ 2 := by
        funext x
        have hx : x ^ 4 + ((1 : ℝ) - 1 ^ 2) ^ 2 = (x ^ 2) ^ 2 := by ring
        rw [hx, Real.sqrt_sq (sq_nonneg x)]
      rw [h]
      simp only [putnam_1991_a5_solution]
      rw [integral_pow]
      norm_num
  · -- upper bound: every attained value is ≤ 1/3
    rintro t ⟨y, ⟨hy0, hy1⟩, rfl⟩
    have hc : (0 : ℝ) ≤ y - y ^ 2 := by nlinarith
    have hint1 : IntervalIntegrable
        (fun x : ℝ => Real.sqrt (x ^ 4 + (y - y ^ 2) ^ 2)) MeasureTheory.volume 0 y := by
      apply Continuous.intervalIntegrable
      fun_prop
    have hintpow : IntervalIntegrable (fun x : ℝ => x ^ 2) MeasureTheory.volume 0 y :=
      (continuous_pow 2).intervalIntegrable 0 y
    have hintconst : IntervalIntegrable (fun _ : ℝ => y - y ^ 2) MeasureTheory.volume 0 y :=
      (continuous_const).intervalIntegrable 0 y
    have hint2 : IntervalIntegrable
        (fun x : ℝ => x ^ 2 + (y - y ^ 2)) MeasureTheory.volume 0 y :=
      hintpow.add hintconst
    have hmono : (∫ x in (0 : ℝ)..y, Real.sqrt (x ^ 4 + (y - y ^ 2) ^ 2))
        ≤ ∫ x in (0 : ℝ)..y, (x ^ 2 + (y - y ^ 2)) := by
      apply integral_mono_on hy0 hint1 hint2
      intro x hx
      rw [show x ^ 4 + (y - y ^ 2) ^ 2 = (x ^ 2) ^ 2 + (y - y ^ 2) ^ 2 by ring]
      calc Real.sqrt ((x ^ 2) ^ 2 + (y - y ^ 2) ^ 2)
            ≤ Real.sqrt ((x ^ 2 + (y - y ^ 2)) ^ 2) := by
              apply Real.sqrt_le_sqrt
              nlinarith [mul_nonneg (sq_nonneg x) hc]
        _ = x ^ 2 + (y - y ^ 2) := Real.sqrt_sq (by positivity)
    have hval : (∫ x in (0 : ℝ)..y, (x ^ 2 + (y - y ^ 2)))
        = y ^ 3 / 3 + (y - y ^ 2) * y := by
      rw [intervalIntegral.integral_add hintpow hintconst, integral_pow, integral_const]
      simp
      ring
    rw [hval] at hmono
    simp only [putnam_1991_a5_solution]
    nlinarith [hmono, mul_nonneg (sq_nonneg (1 - y)) (show (0 : ℝ) ≤ 2 * y + 1 by linarith)]
