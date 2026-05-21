import Mathlib

open MeasureTheory

noncomputable def putnam_1991_a5_solution : ℝ := 1 / 3

theorem putnam_1991_a5 :
    IsGreatest
      {v : ℝ | ∃ y ∈ Set.Icc (0 : ℝ) 1,
        v = ∫ x in (0 : ℝ)..y, Real.sqrt (x ^ 4 + (y - y ^ 2) ^ 2)}
      putnam_1991_a5_solution := by
  constructor
  · -- The value 1/3 is attained at y = 1.
    refine ⟨1, ?_, ?_⟩
    · simp [Set.mem_Icc]
    · unfold putnam_1991_a5_solution
      have hcong : ∀ x ∈ Set.uIcc (0 : ℝ) 1,
          Real.sqrt (x ^ 4 + ((1 : ℝ) - 1 ^ 2) ^ 2) = x ^ 2 := by
        intro x _
        have h0 : ((1 : ℝ) - 1 ^ 2) ^ 2 = 0 := by norm_num
        rw [h0, add_zero, show x ^ 4 = (x ^ 2) ^ 2 by ring, Real.sqrt_sq (sq_nonneg x)]
      rw [intervalIntegral.integral_congr hcong, integral_pow]
      norm_num
  · -- Upper bound: every value is ≤ 1/3.
    rintro v ⟨y, hymem, rfl⟩
    simp only [Set.mem_Icc] at hymem
    obtain ⟨hy0, hy1⟩ := hymem
    set c := y - y ^ 2 with hc
    have hcnn : 0 ≤ c := by rw [hc]; nlinarith
    have hbound : ∀ x ∈ Set.Icc (0 : ℝ) y,
        Real.sqrt (x ^ 4 + c ^ 2) ≤ x ^ 2 + c := by
      intro x _
      rw [show x ^ 4 + c ^ 2 = (x ^ 2) ^ 2 + c ^ 2 by ring]
      have h1 : (x ^ 2) ^ 2 + c ^ 2 ≤ (x ^ 2 + c) ^ 2 := by
        nlinarith [mul_nonneg (sq_nonneg x) hcnn]
      calc Real.sqrt ((x ^ 2) ^ 2 + c ^ 2)
          ≤ Real.sqrt ((x ^ 2 + c) ^ 2) := Real.sqrt_le_sqrt h1
        _ = x ^ 2 + c := Real.sqrt_sq (add_nonneg (sq_nonneg x) hcnn)
    have hf_cont : Continuous (fun x : ℝ => Real.sqrt (x ^ 4 + c ^ 2)) := by
      fun_prop
    have hg_cont : Continuous (fun x : ℝ => x ^ 2 + c) := by fun_prop
    have hint_f : IntervalIntegrable (fun x : ℝ => Real.sqrt (x ^ 4 + c ^ 2))
        volume 0 y := hf_cont.intervalIntegrable 0 y
    have hint_g : IntervalIntegrable (fun x : ℝ => x ^ 2 + c) volume 0 y :=
      hg_cont.intervalIntegrable 0 y
    have hmono : (∫ x in (0 : ℝ)..y, Real.sqrt (x ^ 4 + c ^ 2))
        ≤ ∫ x in (0 : ℝ)..y, (x ^ 2 + c) :=
      intervalIntegral.integral_mono_on hy0 hint_f hint_g hbound
    have hval : (∫ x in (0 : ℝ)..y, (x ^ 2 + c)) = y ^ 3 / 3 + c * y := by
      have hsum : (∫ x in (0 : ℝ)..y, (x ^ 2 + c))
          = (∫ x in (0 : ℝ)..y, x ^ 2) + ∫ _ in (0 : ℝ)..y, c := by
        apply intervalIntegral.integral_add
        · exact (continuous_pow 2).intervalIntegrable 0 y
        · exact intervalIntegrable_const
      rw [hsum, integral_pow, intervalIntegral.integral_const, smul_eq_mul]
      push_cast
      ring
    have hfin : y ^ 3 / 3 + c * y ≤ (1 : ℝ) / 3 := by
      have hk : (0 : ℝ) ≤ (1 - y) ^ 2 * (1 + 2 * y) :=
        mul_nonneg (sq_nonneg _) (by linarith)
      rw [hc]; nlinarith [hk]
    calc (∫ x in (0 : ℝ)..y, Real.sqrt (x ^ 4 + c ^ 2))
        ≤ ∫ x in (0 : ℝ)..y, (x ^ 2 + c) := hmono
      _ = y ^ 3 / 3 + c * y := hval
      _ ≤ putnam_1991_a5_solution := by unfold putnam_1991_a5_solution; exact hfin
