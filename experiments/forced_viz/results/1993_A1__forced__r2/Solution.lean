import Mathlib

open MeasureTheory

/-- Putnam 1993 A1.  The horizontal line `y = c` meets the curve `y = 2x - 3x^3`
in the first quadrant at two points; the value of `c` making the two shaded
areas equal is `4/9`. -/
noncomputable def putnam_1993_a1_solution : ℝ := 4 / 9

theorem putnam_1993_a1 :
    0 < putnam_1993_a1_solution ∧
    putnam_1993_a1_solution < 4 * Real.sqrt 2 / 9 ∧
    (∃ x1 x2 : ℝ, 0 ≤ x1 ∧ x1 < x2 ∧
      2 * x1 - 3 * x1 ^ 3 = putnam_1993_a1_solution ∧
      2 * x2 - 3 * x2 ^ 3 = putnam_1993_a1_solution ∧
      (∫ x in (0:ℝ)..x1, (putnam_1993_a1_solution - (2 * x - 3 * x ^ 3)))
        = (∫ x in x1..x2, ((2 * x - 3 * x ^ 3) - putnam_1993_a1_solution))) := by
  unfold putnam_1993_a1_solution
  refine ⟨by norm_num, ?_, ?_⟩
  · -- 4/9 < 4 * √2 / 9
    have h2 : (1:ℝ) < Real.sqrt 2 := by
      have h := Real.sq_sqrt (show (0:ℝ) ≤ 2 by norm_num)
      nlinarith [Real.sqrt_nonneg 2, h]
    linarith [h2]
  · -- existence of the two intersection points and the area identity
    set s := Real.sqrt 3 with hs_def
    have hs : s ^ 2 = 3 := by rw [hs_def]; exact Real.sq_sqrt (by norm_num)
    have hsnn : 0 ≤ s := by rw [hs_def]; exact Real.sqrt_nonneg 3
    have hs1 : 1 ≤ s := by nlinarith [hs, hsnn]
    have hs3 : s < 3 := by nlinarith [hs, hsnn]
    -- the integrand of the first region
    have hcont : Continuous (fun x : ℝ => (4:ℝ)/9 - (2 * x - 3 * x ^ 3)) := by
      fun_prop
    -- antiderivative gives ∫₀^{2/3} (4/9 - (2x - 3x³)) dx = 0
    have hderiv : ∀ x : ℝ,
        HasDerivAt (fun y : ℝ => (4:ℝ)/9 * y - y ^ 2 + (3:ℝ)/4 * y ^ 4)
          ((4:ℝ)/9 - (2 * x - 3 * x ^ 3)) x := by
      intro x
      have e1 : HasDerivAt (fun y : ℝ => (4:ℝ)/9 * y) ((4:ℝ)/9) x := by
        simpa using (hasDerivAt_id x).const_mul ((4:ℝ)/9)
      have e2 : HasDerivAt (fun y : ℝ => y ^ 2) ((2:ℝ) * x) x := by
        simpa using hasDerivAt_pow 2 x
      have e3 : HasDerivAt (fun y : ℝ => (3:ℝ)/4 * y ^ 4) ((3:ℝ)/4 * (4 * x ^ 3)) x := by
        simpa using (hasDerivAt_pow 4 x).const_mul ((3:ℝ)/4)
      have e := (e1.sub e2).add e3
      convert e using 1
      ring
    have key : (∫ x in (0:ℝ)..(2/3), ((4:ℝ)/9 - (2 * x - 3 * x ^ 3))) = 0 := by
      rw [intervalIntegral.integral_eq_sub_of_hasDerivAt
            (fun x _ => hderiv x) (hcont.intervalIntegrable _ _)]
      norm_num
    have hadj :
        (∫ x in (0:ℝ)..(s - 1)/3, ((4:ℝ)/9 - (2 * x - 3 * x ^ 3)))
          + (∫ x in ((s - 1)/3)..(2/3), ((4:ℝ)/9 - (2 * x - 3 * x ^ 3)))
          = (∫ x in (0:ℝ)..(2/3), ((4:ℝ)/9 - (2 * x - 3 * x ^ 3))) :=
      intervalIntegral.integral_add_adjacent_intervals
        (hcont.intervalIntegrable _ _) (hcont.intervalIntegrable _ _)
    refine ⟨(s - 1)/3, 2/3, by linarith [hs1], by linarith [hs3], ?_, ?_, ?_⟩
    · -- 2·x₁ - 3·x₁³ = 4/9
      linear_combination ((3 - s)/9) * hs
    · -- 2·x₂ - 3·x₂³ = 4/9
      norm_num
    · -- the area identity
      have hneg :
          (∫ x in ((s - 1)/3)..(2/3), ((2 * x - 3 * x ^ 3) - (4:ℝ)/9))
            = - (∫ x in ((s - 1)/3)..(2/3), ((4:ℝ)/9 - (2 * x - 3 * x ^ 3))) := by
        rw [← intervalIntegral.integral_neg]
        exact intervalIntegral.integral_congr (fun x _ => by ring)
      rw [hneg]
      linear_combination hadj.trans key
