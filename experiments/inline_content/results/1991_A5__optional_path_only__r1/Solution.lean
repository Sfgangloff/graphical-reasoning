import Mathlib

open Real

noncomputable def putnam_1991_a5_solution : ℝ := 1 / 3

theorem putnam_1991_a5 :
    IsGreatest
      {t : ℝ | ∃ y ∈ Set.Icc (0 : ℝ) 1,
        t = ∫ x in (0 : ℝ)..y, Real.sqrt (x ^ 4 + (y - y ^ 2) ^ 2)}
      putnam_1991_a5_solution := by
  constructor
  · -- membership: y = 1 achieves 1/3
    refine ⟨1, ⟨by norm_num, by norm_num⟩, ?_⟩
    unfold putnam_1991_a5_solution
    have h : (∫ x in (0:ℝ)..1, Real.sqrt (x ^ 4 + ((1:ℝ) - 1 ^ 2) ^ 2))
        = ∫ x in (0:ℝ)..1, x ^ 2 := by
      apply intervalIntegral.integral_congr
      intro x hx
      show Real.sqrt (x ^ 4 + ((1:ℝ) - 1 ^ 2) ^ 2) = x ^ 2
      rw [show ((1:ℝ) - 1 ^ 2) ^ 2 = 0 by ring, add_zero, show x ^ 4 = (x ^ 2) ^ 2 by ring]
      exact Real.sqrt_sq (sq_nonneg x)
    rw [h, integral_pow]
    norm_num
  · -- upper bound
    rintro t ⟨y, ⟨hy0, hy1⟩, rfl⟩
    set c := y - y ^ 2 with hc
    have hcnn : 0 ≤ c := by rw [hc]; nlinarith
    have hle : (∫ x in (0:ℝ)..y, Real.sqrt (x ^ 4 + c ^ 2))
        ≤ ∫ x in (0:ℝ)..y, (x ^ 2 + c) := by
      apply intervalIntegral.integral_mono_on hy0
      · exact (Real.continuous_sqrt.comp (by continuity)).intervalIntegrable _ _
      · exact (by continuity : Continuous fun x : ℝ => x ^ 2 + c).intervalIntegrable _ _
      · intro x hx
        have hx2 : (0:ℝ) ≤ x ^ 2 := sq_nonneg x
        rw [show x ^ 4 = (x ^ 2) ^ 2 by ring]
        calc Real.sqrt ((x ^ 2) ^ 2 + c ^ 2)
            ≤ Real.sqrt ((x ^ 2 + c) ^ 2) := by
                apply Real.sqrt_le_sqrt; nlinarith [mul_nonneg hx2 hcnn]
          _ = x ^ 2 + c := Real.sqrt_sq (by positivity)
    have hcomp : (∫ x in (0:ℝ)..y, (x ^ 2 + c)) = y ^ 3 / 3 + y * c := by
      rw [intervalIntegral.integral_add ((continuous_pow 2).intervalIntegrable _ _)
        (intervalIntegrable_const), integral_pow, intervalIntegral.integral_const]
      simp
      ring
    rw [hcomp] at hle
    refine le_trans hle ?_
    show y ^ 3 / 3 + y * c ≤ putnam_1991_a5_solution
    rw [hc]
    unfold putnam_1991_a5_solution
    nlinarith [mul_nonneg (sq_nonneg (y - 1)) (by linarith : (0:ℝ) ≤ 2 * y + 1)]
