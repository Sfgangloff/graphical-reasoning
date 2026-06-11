import Mathlib

open intervalIntegral MeasureTheory

noncomputable def putnam_1991_a5_solution : ℝ := 1/3

theorem putnam_1991_a5 :
    IsGreatest
      {t : ℝ | ∃ y ∈ Set.Icc (0:ℝ) 1,
        t = ∫ x in (0:ℝ)..y, Real.sqrt (x ^ 4 + (y - y ^ 2) ^ 2)}
      putnam_1991_a5_solution := by
  constructor
  · -- membership: attained at y = 1
    refine ⟨1, by norm_num, ?_⟩
    have hcongr : (∫ x in (0:ℝ)..1, Real.sqrt (x ^ 4 + ((1:ℝ) - 1 ^ 2) ^ 2))
        = ∫ x in (0:ℝ)..1, x ^ 2 := by
      apply intervalIntegral.integral_congr
      intro x _
      show Real.sqrt (x ^ 4 + ((1:ℝ) - 1 ^ 2) ^ 2) = x ^ 2
      rw [show ((1:ℝ) - 1 ^ 2) ^ 2 = 0 by ring, add_zero, show x ^ 4 = (x ^ 2) ^ 2 by ring]
      exact Real.sqrt_sq (sq_nonneg x)
    rw [putnam_1991_a5_solution, hcongr, integral_pow]
    norm_num
  · -- upper bound 1/3
    rintro t ⟨y, hy, rfl⟩
    obtain ⟨hy0, hy1⟩ := hy
    set c := y - y ^ 2 with hc
    have hcnn : 0 ≤ c := by
      rw [hc]; nlinarith [mul_nonneg hy0 (sub_nonneg.mpr hy1)]
    have hbound : ∀ x : ℝ, Real.sqrt (x ^ 4 + c ^ 2) ≤ x ^ 2 + c := by
      intro x
      have h1 : x ^ 4 + c ^ 2 ≤ (x ^ 2 + c) ^ 2 := by nlinarith [sq_nonneg x, hcnn]
      have h2 : (0:ℝ) ≤ x ^ 2 + c := by positivity
      calc Real.sqrt (x ^ 4 + c ^ 2) ≤ Real.sqrt ((x ^ 2 + c) ^ 2) := Real.sqrt_le_sqrt h1
        _ = x ^ 2 + c := Real.sqrt_sq h2
    have hint1 : IntervalIntegrable (fun x => Real.sqrt (x ^ 4 + c ^ 2)) volume 0 y :=
      (((continuous_pow 4).add continuous_const).sqrt).intervalIntegrable 0 y
    have hint2 : IntervalIntegrable (fun x : ℝ => x ^ 2 + c) volume 0 y :=
      (((continuous_pow 2).add continuous_const)).intervalIntegrable 0 y
    have hmono : (∫ x in (0:ℝ)..y, Real.sqrt (x ^ 4 + c ^ 2))
        ≤ ∫ x in (0:ℝ)..y, (x ^ 2 + c) := by
      apply intervalIntegral.integral_mono_on hy0 hint1 hint2
      intro x _
      exact hbound x
    have hval : (∫ x in (0:ℝ)..y, (x ^ 2 + c)) = y ^ 3 / 3 + c * y := by
      rw [intervalIntegral.integral_add ((continuous_pow 2).intervalIntegrable 0 y)
        (intervalIntegral.intervalIntegrable_const), integral_pow, intervalIntegral.integral_const]
      simp only [smul_eq_mul]
      ring
    rw [putnam_1991_a5_solution]
    calc (∫ x in (0:ℝ)..y, Real.sqrt (x ^ 4 + c ^ 2))
          ≤ ∫ x in (0:ℝ)..y, (x ^ 2 + c) := hmono
      _ = y ^ 3 / 3 + c * y := hval
      _ ≤ 1 / 3 := by
          rw [hc]
          nlinarith [mul_nonneg (sq_nonneg (y - 1)) (show (0:ℝ) ≤ 2 * y + 1 by linarith)]
