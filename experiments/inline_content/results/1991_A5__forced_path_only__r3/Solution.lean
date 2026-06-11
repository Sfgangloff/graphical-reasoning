import Mathlib

open MeasureTheory intervalIntegral

noncomputable def putnam_1991_a5_solution : ℝ := 1 / 3

theorem putnam_1991_a5 :
    IsGreatest {t : ℝ | ∃ y ∈ Set.Icc (0:ℝ) 1,
      t = ∫ x in (0:ℝ)..y, Real.sqrt (x ^ 4 + (y - y ^ 2) ^ 2)}
      putnam_1991_a5_solution := by
  constructor
  · -- membership: the value 1/3 is attained at y = 1
    refine ⟨1, ⟨by norm_num, le_refl 1⟩, ?_⟩
    have heq : ∀ x : ℝ, Real.sqrt (x ^ 4 + ((1:ℝ) - 1 ^ 2) ^ 2) = x ^ 2 := by
      intro x
      have : ((1:ℝ) - 1 ^ 2) ^ 2 = 0 := by norm_num
      rw [this, add_zero, show x ^ 4 = (x ^ 2) ^ 2 by ring, Real.sqrt_sq (sq_nonneg x)]
    simp only [putnam_1991_a5_solution]
    rw [show (fun x : ℝ => Real.sqrt (x ^ 4 + ((1:ℝ) - 1 ^ 2) ^ 2)) = fun x : ℝ => x ^ 2 from
        funext heq]
    rw [integral_pow]
    norm_num
  · -- upper bound: every attained value is ≤ 1/3
    rintro t ⟨y, hy, rfl⟩
    rw [Set.mem_Icc] at hy
    obtain ⟨hy0, hy1⟩ := hy
    set c := y - y ^ 2 with hc_def
    have hc : 0 ≤ c := by rw [hc_def]; nlinarith
    have hbound : (∫ x in (0:ℝ)..y, Real.sqrt (x ^ 4 + c ^ 2))
        ≤ ∫ x in (0:ℝ)..y, (x ^ 2 + c) := by
      apply intervalIntegral.integral_mono_on hy0
      · exact (by fun_prop : Continuous fun x : ℝ => Real.sqrt (x ^ 4 + c ^ 2)).intervalIntegrable 0 y
      · exact (by fun_prop : Continuous fun x : ℝ => x ^ 2 + c).intervalIntegrable 0 y
      · intro x _
        have h1 : x ^ 4 + c ^ 2 ≤ (x ^ 2 + c) ^ 2 := by
          nlinarith [mul_nonneg (sq_nonneg x) hc]
        calc Real.sqrt (x ^ 4 + c ^ 2) ≤ Real.sqrt ((x ^ 2 + c) ^ 2) := Real.sqrt_le_sqrt h1
          _ = x ^ 2 + c := Real.sqrt_sq (add_nonneg (sq_nonneg x) hc)
    have hint1 : IntervalIntegrable (fun x : ℝ => x ^ 2) volume 0 y :=
      (by fun_prop : Continuous fun x : ℝ => x ^ 2).intervalIntegrable 0 y
    have hint2 : IntervalIntegrable (fun _ : ℝ => c) volume 0 y :=
      intervalIntegral.intervalIntegrable_const
    have hrhs : (∫ x in (0:ℝ)..y, (x ^ 2 + c)) = y ^ 3 / 3 + y * c := by
      rw [intervalIntegral.integral_add hint1 hint2, integral_pow,
        intervalIntegral.integral_const]
      simp only [smul_eq_mul]
      ring
    rw [hrhs] at hbound
    refine le_trans hbound ?_
    rw [hc_def]
    simp only [putnam_1991_a5_solution]
    nlinarith [mul_nonneg (sq_nonneg (y - 1)) (show (0:ℝ) ≤ 2 * y + 1 by linarith)]
