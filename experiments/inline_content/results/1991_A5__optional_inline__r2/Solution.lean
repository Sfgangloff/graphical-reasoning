import Mathlib

open Set

noncomputable def putnam_1991_a5_solution : ℝ := 1 / 3

theorem putnam_1991_a5 :
    IsGreatest {y : ℝ | ∃ x ∈ Set.Icc (0:ℝ) 1,
      y = ∫ t in (0:ℝ)..x, Real.sqrt (t ^ 4 + (x - x ^ 2) ^ 2)}
      putnam_1991_a5_solution := by
  constructor
  · -- membership: x = 1 gives 1/3
    refine ⟨1, ⟨by norm_num, le_refl 1⟩, ?_⟩
    have : ∀ t ∈ Set.uIcc (0:ℝ) 1,
        Real.sqrt (t ^ 4 + ((1:ℝ) - 1 ^ 2) ^ 2) = t ^ 2 := by
      intro t ht
      have h4 : t ^ 4 + ((1:ℝ) - 1 ^ 2) ^ 2 = (t ^ 2) ^ 2 := by ring
      rw [h4, Real.sqrt_sq (by positivity)]
    rw [intervalIntegral.integral_congr this]
    rw [putnam_1991_a5_solution]
    simp [integral_pow]
    norm_num
  · -- upper bound
    rintro y ⟨x, ⟨hx0, hx1⟩, rfl⟩
    have hc : (0:ℝ) ≤ x - x ^ 2 := by nlinarith
    -- pointwise bound: sqrt(t^4 + c^2) ≤ t^2 + c
    have hbound : ∀ t ∈ Set.uIcc (0:ℝ) x,
        Real.sqrt (t ^ 4 + (x - x ^ 2) ^ 2) ≤ t ^ 2 + (x - x ^ 2) := by
      intro t _
      rw [show t ^ 4 + (x - x ^ 2) ^ 2 = (t ^ 2) ^ 2 + (x - x ^ 2) ^ 2 by ring]
      rw [show t ^ 2 + (x - x ^ 2) = Real.sqrt ((t ^ 2 + (x - x ^ 2)) ^ 2) from
        (Real.sqrt_sq (by positivity)).symm]
      apply Real.sqrt_le_sqrt
      nlinarith [sq_nonneg t, mul_nonneg (sq_nonneg t) hc]
    have hint1 : IntervalIntegrable
        (fun t => Real.sqrt (t ^ 4 + (x - x ^ 2) ^ 2)) MeasureTheory.volume 0 x := by
      apply Continuous.intervalIntegrable
      fun_prop
    have hint2 : IntervalIntegrable
        (fun t => t ^ 2 + (x - x ^ 2)) MeasureTheory.volume 0 x := by
      apply Continuous.intervalIntegrable
      fun_prop
    have hmono : (∫ t in (0:ℝ)..x, Real.sqrt (t ^ 4 + (x - x ^ 2) ^ 2))
        ≤ ∫ t in (0:ℝ)..x, (t ^ 2 + (x - x ^ 2)) := by
      apply intervalIntegral.integral_mono_on hx0 hint1 hint2
      intro t ht
      exact hbound t (by rw [Set.uIcc_of_le hx0]; exact ht)
    have hval : (∫ t in (0:ℝ)..x, (t ^ 2 + (x - x ^ 2)))
        = x ^ 3 / 3 + (x - x ^ 2) * x := by
      rw [intervalIntegral.integral_add (by apply Continuous.intervalIntegrable; fun_prop)
        (by apply Continuous.intervalIntegrable; fun_prop)]
      rw [integral_pow]
      simp
      ring
    rw [hval] at hmono
    have : x ^ 3 / 3 + (x - x ^ 2) * x ≤ 1 / 3 := by nlinarith [sq_nonneg (x - 1)]
    rw [putnam_1991_a5_solution]
    linarith
