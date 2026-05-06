import Mathlib

open Real MeasureTheory intervalIntegral

noncomputable def putnam_1993_a1_solution : ℝ := 4 / 9

theorem putnam_1993_a1 (c : ℝ) (x₁ x₂ : ℝ)
    (hx₁ : 0 < x₁) (hx₁₂ : x₁ < x₂)
    (h₁ : 2 * x₁ - 3 * x₁ ^ 3 = c)
    (h₂ : 2 * x₂ - 3 * x₂ ^ 3 = c)
    (heq : (∫ x in (0:ℝ)..x₁, (c - (2 * x - 3 * x ^ 3))) =
           ∫ x in x₁..x₂, ((2 * x - 3 * x ^ 3) - c)) :
    c = putnam_1993_a1_solution := by
  have hx₂pos : 0 < x₂ := lt_trans hx₁ hx₁₂
  have hcomb : (∫ x in (0:ℝ)..x₂, (c - (2 * x - 3 * x ^ 3))) = 0 := by
    have hcont : Continuous (fun x : ℝ => c - (2 * x - 3 * x ^ 3)) :=
      continuous_const.sub
        ((continuous_const.mul continuous_id).sub
          (continuous_const.mul (continuous_pow 3)))
    have hsplit : (∫ x in (0:ℝ)..x₂, (c - (2 * x - 3 * x ^ 3))) =
        (∫ x in (0:ℝ)..x₁, (c - (2 * x - 3 * x ^ 3))) +
        (∫ x in x₁..x₂, (c - (2 * x - 3 * x ^ 3))) := by
      rw [intervalIntegral.integral_add_adjacent_intervals
        (hcont.intervalIntegrable _ _) (hcont.intervalIntegrable _ _)]
    have hneg : (∫ x in x₁..x₂, (c - (2 * x - 3 * x ^ 3))) =
        - ∫ x in x₁..x₂, ((2 * x - 3 * x ^ 3) - c) := by
      rw [← intervalIntegral.integral_neg]
      congr 1; ext x; ring
    rw [hsplit, hneg, heq]; ring
  have hint : (∫ x in (0:ℝ)..x₂, (c - (2 * x - 3 * x ^ 3))) =
      c * x₂ - x₂ ^ 2 + (3/4) * x₂ ^ 4 := by
    have h1 : (∫ _ in (0:ℝ)..x₂, c) = c * x₂ := by
      rw [intervalIntegral.integral_const]; ring
    have h2 : (∫ x in (0:ℝ)..x₂, (2 * x : ℝ)) = x₂ ^ 2 := by
      rw [intervalIntegral.integral_const_mul, integral_id]; ring
    have h3 : (∫ x in (0:ℝ)..x₂, (3 * x ^ 3 : ℝ)) = (3/4) * x₂ ^ 4 := by
      rw [intervalIntegral.integral_const_mul, integral_pow]; ring
    have hcc : IntervalIntegrable (fun _ : ℝ => c) MeasureTheory.volume 0 x₂ :=
      _root_.intervalIntegrable_const
    have hf : IntervalIntegrable (fun x : ℝ => 2 * x - 3 * x ^ 3) MeasureTheory.volume 0 x₂ :=
      ((continuous_const.mul continuous_id).sub
        (continuous_const.mul (continuous_pow 3))).intervalIntegrable _ _
    have h2x : IntervalIntegrable (fun x : ℝ => 2 * x) MeasureTheory.volume 0 x₂ :=
      (continuous_const.mul continuous_id).intervalIntegrable _ _
    have h3x : IntervalIntegrable (fun x : ℝ => 3 * x ^ 3) MeasureTheory.volume 0 x₂ :=
      (continuous_const.mul (continuous_pow 3)).intervalIntegrable _ _
    rw [intervalIntegral.integral_sub hcc hf, intervalIntegral.integral_sub h2x h3x,
        h1, h2, h3]; ring
  rw [hint] at hcomb
  have hx₂eq : x₂ ^ 2 = 4 / 9 := by
    have hsub : (2 * x₂ - 3 * x₂ ^ 3) * x₂ - x₂ ^ 2 + (3 / 4) * x₂ ^ 4 = 0 := by
      rw [h₂]; exact hcomb
    have hpoly : x₂ ^ 2 * (1 - (9 / 4) * x₂ ^ 2) = 0 := by nlinarith [hsub]
    have hx₂sq : x₂ ^ 2 ≠ 0 := pow_ne_zero 2 (ne_of_gt hx₂pos)
    have : 1 - (9 / 4) * x₂ ^ 2 = 0 := by
      rcases mul_eq_zero.mp hpoly with h | h
      · exact absurd h hx₂sq
      · exact h
    linarith
  have hx₂val : x₂ = 2 / 3 := by
    nlinarith [hx₂eq, hx₂pos, sq_nonneg (x₂ - 2/3), sq_nonneg (x₂ + 2/3)]
  rw [hx₂val] at h₂
  unfold putnam_1993_a1_solution
  nlinarith [h₂]
