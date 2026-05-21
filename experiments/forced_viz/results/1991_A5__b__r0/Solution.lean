import Mathlib

open Set intervalIntegral MeasureTheory

noncomputable def putnam_1991_a5_solution : ℝ := 1 / 3

theorem putnam_1991_a5 :
    IsGreatest
      {z : ℝ | ∃ y ∈ Set.Icc (0 : ℝ) 1,
        ∫ x in (0:ℝ)..y, Real.sqrt (x ^ 4 + (y - y ^ 2) ^ 2) = z}
      putnam_1991_a5_solution := by
  constructor
  · -- membership: y = 1 gives the integral 1/3
    refine ⟨1, by norm_num, ?_⟩
    have heq : ∀ x : ℝ, Real.sqrt (x ^ 4 + ((1:ℝ) - 1 ^ 2) ^ 2) = x ^ 2 := by
      intro x
      have h : (x:ℝ) ^ 4 + ((1:ℝ) - 1 ^ 2) ^ 2 = (x ^ 2) ^ 2 := by ring
      rw [h, Real.sqrt_sq (by positivity)]
    simp_rw [heq]
    rw [integral_pow]
    norm_num [putnam_1991_a5_solution]
  · -- every value of the integral is ≤ 1/3
    rintro z ⟨y, hy, rfl⟩
    obtain ⟨hy0, hy1⟩ := hy
    set c : ℝ := y - y ^ 2 with hc
    have hcnn : 0 ≤ c := by rw [hc]; nlinarith
    have hbound : ∀ x ∈ Set.Icc (0:ℝ) y,
        Real.sqrt (x ^ 4 + c ^ 2) ≤ x ^ 2 + c := by
      intro x hx
      have h1 : x ^ 4 + c ^ 2 ≤ (x ^ 2 + c) ^ 2 := by nlinarith [sq_nonneg x]
      calc Real.sqrt (x ^ 4 + c ^ 2)
          ≤ Real.sqrt ((x ^ 2 + c) ^ 2) := Real.sqrt_le_sqrt h1
        _ = x ^ 2 + c := Real.sqrt_sq (by positivity)
    have hcont1 : Continuous (fun x : ℝ => Real.sqrt (x ^ 4 + c ^ 2)) := by fun_prop
    have hcont2 : Continuous (fun x : ℝ => x ^ 2 + c) := by fun_prop
    have hint : (∫ x in (0:ℝ)..y, Real.sqrt (x ^ 4 + c ^ 2))
        ≤ ∫ x in (0:ℝ)..y, (x ^ 2 + c) := by
      apply intervalIntegral.integral_mono_on hy0
      · exact hcont1.intervalIntegrable _ _
      · exact hcont2.intervalIntegrable _ _
      · exact hbound
    have hval : (∫ x in (0:ℝ)..y, (x ^ 2 + c)) = y ^ 3 / 3 + c * y := by
      rw [intervalIntegral.integral_add
            ((by fun_prop : Continuous (fun x : ℝ => x ^ 2)).intervalIntegrable _ _)
            (_root_.intervalIntegrable_const)]
      rw [integral_pow, intervalIntegral.integral_const]
      ring
    rw [hval] at hint
    have hfin : y ^ 3 / 3 + c * y ≤ (1:ℝ) / 3 := by
      rw [hc]; nlinarith [sq_nonneg (y - 1)]
    show _ ≤ putnam_1991_a5_solution
    rw [putnam_1991_a5_solution]
    linarith [hint, hfin]
