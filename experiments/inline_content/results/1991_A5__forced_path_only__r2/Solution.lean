import Mathlib

open scoped Real

noncomputable def putnam_1991_a5_solution : ℝ := 1 / 3

theorem putnam_1991_a5 :
    IsGreatest
      {t : ℝ | ∃ y ∈ Set.Icc (0 : ℝ) 1,
        t = ∫ x in (0:ℝ)..y, Real.sqrt (x ^ 4 + (y - y ^ 2) ^ 2)}
      putnam_1991_a5_solution := by
  constructor
  · -- membership: achieved at y = 1
    refine ⟨1, by norm_num, ?_⟩
    rw [putnam_1991_a5_solution]
    have heq : (∫ x in (0:ℝ)..1, Real.sqrt (x ^ 4 + ((1:ℝ) - 1 ^ 2) ^ 2))
        = ∫ x in (0:ℝ)..1, x ^ 2 := by
      apply intervalIntegral.integral_congr
      intro x hx
      dsimp only
      have h0 : ((1:ℝ) - 1 ^ 2) ^ 2 = 0 := by norm_num
      rw [h0, add_zero, show x ^ 4 = (x ^ 2) ^ 2 by ring]
      exact Real.sqrt_sq (sq_nonneg x)
    rw [heq, integral_pow]
    norm_num
  · -- upper bound
    rintro t ⟨y, hy, rfl⟩
    obtain ⟨hy0, hy1⟩ := hy
    set c : ℝ := y - y ^ 2 with hc
    have hcnonneg : 0 ≤ c := by rw [hc]; nlinarith [hy0, hy1]
    have hbound : ∀ x ∈ Set.Icc (0:ℝ) y,
        Real.sqrt (x ^ 4 + c ^ 2) ≤ x ^ 2 + c := by
      intro x hx
      rw [show x ^ 4 + c ^ 2 = (x ^ 2) ^ 2 + c ^ 2 by ring]
      calc Real.sqrt ((x ^ 2) ^ 2 + c ^ 2)
          ≤ Real.sqrt ((x ^ 2 + c) ^ 2) := by
            apply Real.sqrt_le_sqrt
            nlinarith [hcnonneg, sq_nonneg x]
        _ = x ^ 2 + c := Real.sqrt_sq (by positivity)
    have hint1 : IntervalIntegrable (fun x => Real.sqrt (x ^ 4 + c ^ 2))
        MeasureTheory.volume 0 y := by
      apply Continuous.intervalIntegrable; fun_prop
    have hint2 : IntervalIntegrable (fun x => x ^ 2 + c)
        MeasureTheory.volume 0 y := by
      apply Continuous.intervalIntegrable; fun_prop
    rw [putnam_1991_a5_solution]
    calc (∫ x in (0:ℝ)..y, Real.sqrt (x ^ 4 + c ^ 2))
        ≤ ∫ x in (0:ℝ)..y, (x ^ 2 + c) :=
          intervalIntegral.integral_mono_on hy0 hint1 hint2 hbound
      _ = y ^ 3 / 3 + c * y := by
          rw [intervalIntegral.integral_add
            (by apply Continuous.intervalIntegrable; fun_prop)
            (by apply Continuous.intervalIntegrable; fun_prop),
            integral_pow, intervalIntegral.integral_const]
          simp; ring
      _ ≤ 1 / 3 := by
          rw [hc]
          nlinarith [mul_nonneg (sq_nonneg (y - 1)) (by linarith : (0:ℝ) ≤ 2 * y + 1)]
