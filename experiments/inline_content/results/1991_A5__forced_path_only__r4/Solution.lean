import Mathlib

open scoped Real

noncomputable def putnam_1991_a5_solution : ℝ := 1 / 3

theorem putnam_1991_a5 :
    IsGreatest
      {t : ℝ | ∃ y ∈ Set.Icc (0 : ℝ) 1,
        t = ∫ x in (0 : ℝ)..y, Real.sqrt (x ^ 4 + (y - y ^ 2) ^ 2)}
      putnam_1991_a5_solution := by
  constructor
  · -- the value 1/3 is attained at y = 1
    refine ⟨1, ?_, ?_⟩
    · simp [Set.mem_Icc]
    · have : (∫ x in (0 : ℝ)..1, Real.sqrt (x ^ 4 + ((1:ℝ) - 1 ^ 2) ^ 2))
          = ∫ x in (0 : ℝ)..1, x ^ 2 := by
        apply intervalIntegral.integral_congr
        intro x hx
        rw [Set.uIcc_of_le (by norm_num)] at hx
        have hx0 : 0 ≤ x := hx.1
        simp only [one_pow, sub_self]
        rw [show ((0:ℝ))^2 = 0 by ring, add_zero]
        rw [show x ^ 4 = (x ^ 2) ^ 2 by ring]
        rw [Real.sqrt_sq (by positivity)]
      rw [putnam_1991_a5_solution, this]
      simp [integral_pow]
      norm_num
  · -- 1/3 is an upper bound
    rintro t ⟨y, hy, rfl⟩
    rw [Set.mem_Icc] at hy
    obtain ⟨hy0, hy1⟩ := hy
    have hc : (0:ℝ) ≤ y - y ^ 2 := by nlinarith
    -- pointwise bound: sqrt(x^4 + c^2) ≤ x^2 + c  on [0,y]
    have hbound : (∫ x in (0 : ℝ)..y, Real.sqrt (x ^ 4 + (y - y ^ 2) ^ 2))
        ≤ ∫ x in (0 : ℝ)..y, (x ^ 2 + (y - y ^ 2)) := by
      apply intervalIntegral.integral_mono_on hy0
      · -- integrability of sqrt(...)
        apply Continuous.intervalIntegrable
        fun_prop
      · apply Continuous.intervalIntegrable
        fun_prop
      · intro x hx
        have hx0 : 0 ≤ x := hx.1
        have h2 : x ^ 4 + (y - y ^ 2) ^ 2 ≤ (x ^ 2 + (y - y ^ 2)) ^ 2 := by
          nlinarith [hc, sq_nonneg x, mul_nonneg hc (sq_nonneg x)]
        calc Real.sqrt (x ^ 4 + (y - y ^ 2) ^ 2)
            ≤ Real.sqrt ((x ^ 2 + (y - y ^ 2)) ^ 2) := Real.sqrt_le_sqrt h2
          _ = x ^ 2 + (y - y ^ 2) := Real.sqrt_sq (add_nonneg (sq_nonneg x) hc)
    -- compute the bounding integral
    have hcompute : (∫ x in (0 : ℝ)..y, (x ^ 2 + (y - y ^ 2)))
        = y ^ 3 / 3 + (y - y ^ 2) * y := by
      rw [intervalIntegral.integral_add]
      · rw [integral_pow]
        simp
        ring
      · apply Continuous.intervalIntegrable; fun_prop
      · apply Continuous.intervalIntegrable; fun_prop
    rw [putnam_1991_a5_solution]
    rw [hcompute] at hbound
    refine hbound.trans ?_
    nlinarith [sq_nonneg y, sq_nonneg (y - 1), mul_nonneg hy0 (sub_nonneg.mpr hy1)]
