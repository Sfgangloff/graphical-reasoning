import Mathlib

open Real BigOperators

noncomputable def putnam_2018_a3_solution : ℝ := 480 / 49

-- The witness: 7 angles with cos = -3/7, 3 angles equal to 0.
noncomputable def witness : Fin 10 → ℝ :=
  fun i => if (i : ℕ) < 7 then Real.arccos (-3 / 7) else 0

lemma neg_three_div_seven_mem : (-3 / 7 : ℝ) ∈ Set.Icc (-1 : ℝ) 1 := by
  constructor <;> norm_num

lemma cos_witness (i : Fin 10) :
    Real.cos (witness i) = if (i : ℕ) < 7 then (-3 / 7 : ℝ) else 1 := by
  unfold witness
  split_ifs with h
  · exact Real.cos_arccos (by norm_num) (by norm_num)
  · exact Real.cos_zero

lemma cos_three_witness (i : Fin 10) :
    Real.cos (3 * witness i) = if (i : ℕ) < 7 then (333 / 343 : ℝ) else 1 := by
  rw [Real.cos_three_mul]
  rw [cos_witness]
  split_ifs with h
  · ring
  · ring

lemma sum_cos_witness : (∑ i, Real.cos (witness i)) = 0 := by
  simp only [cos_witness]
  simp only [Fin.sum_univ_succ, Fin.sum_univ_zero]
  norm_num

lemma sum_cos_three_witness :
    (∑ i, Real.cos (3 * witness i)) = 480 / 49 := by
  simp only [cos_three_witness]
  simp only [Fin.sum_univ_succ, Fin.sum_univ_zero]
  norm_num

theorem putnam_2018_a3 :
  IsGreatest
    {t : ℝ | ∃ x : Fin 10 → ℝ,
      (∑ i, Real.cos (x i)) = 0 ∧ (∑ i, Real.cos (3 * x i)) = t}
    putnam_2018_a3_solution := by
  refine ⟨⟨witness, sum_cos_witness, sum_cos_three_witness⟩, ?_⟩
  rintro t ⟨x, hsum, ht⟩
  sorry
