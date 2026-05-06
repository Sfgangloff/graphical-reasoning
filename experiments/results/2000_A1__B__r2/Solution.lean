import Mathlib

open Real

noncomputable def putnam_2000_a1_solution : ℝ → Set ℝ := fun A => Set.Ioo 0 (A^2)

theorem putnam_2000_a1 (A : ℝ) (hA : 0 < A) :
    {S : ℝ | ∃ x : ℕ → ℝ, (∀ j, 0 < x j) ∧ HasSum x A ∧ HasSum (fun j => (x j)^2) S}
      = putnam_2000_a1_solution A := by
  ext S
  simp only [putnam_2000_a1_solution, Set.mem_setOf_eq, Set.mem_Ioo]
  constructor
  · rintro ⟨x, hxpos, hxsum, hxsq⟩
    have hxnn : ∀ j, 0 ≤ x j := fun j => (hxpos j).le
    -- For any j, x j + x (j+1) ≤ A
    have hxpair : ∀ j, x j + x (j+1) ≤ A := by
      intro j
      have h := sum_le_hasSum (s := ({j, j+1} : Finset ℕ)) (f := x)
        (fun i _ => hxnn i) hxsum
      rw [Finset.sum_pair (by omega : j ≠ j+1)] at h
      exact h
    have hxlt : ∀ j, x j < A := by
      intro j
      have hp := hxpair j
      have := hxpos (j+1)
      linarith
    refine ⟨?_, ?_⟩
    · -- 0 < S: x 0 ^ 2 ≤ S, and x 0 ^ 2 > 0
      have h0 := sum_le_hasSum (s := ({0} : Finset ℕ)) (f := fun j => (x j)^2)
        (fun i _ => sq_nonneg _) hxsq
      rw [Finset.sum_singleton] at h0
      have := sq_pos_of_pos (hxpos 0)
      linarith
    · -- S < A^2
      have hAx : HasSum (fun j => A * x j) (A * A) := hxsum.mul_left A
      have hpoint : ∀ j, (x j)^2 ≤ A * x j := by
        intro j
        have hl := hxlt j
        have hn := hxnn j
        nlinarith
      have hpoint_strict : (x 0)^2 < A * x 0 := by
        have hl := hxlt 0
        have hp := hxpos 0
        nlinarith
      have hkey := Summable.tsum_lt_tsum_of_nonneg
        (fun b => sq_nonneg _) hpoint hpoint_strict (hAx.summable)
      rw [hxsq.tsum_eq, hAx.tsum_eq] at hkey
      have : A * A = A^2 := by ring
      linarith
  · rintro ⟨hS_pos, hS_lt⟩
    have hA2pos : 0 < A^2 := by positivity
    have hA2_S_pos : 0 < A^2 + S := by linarith
    have hA2_S_diff_pos : 0 < A^2 - S := by linarith
    set r : ℝ := (A^2 - S) / (A^2 + S) with hr_def
    have hr_pos : 0 < r := div_pos hA2_S_diff_pos hA2_S_pos
    have hr_lt : r < 1 := by
      rw [hr_def, div_lt_one hA2_S_pos]
      linarith
    have hr_nonneg : 0 ≤ r := hr_pos.le
    have h1mr_pos : 0 < 1 - r := by linarith
    have h1pr_pos : 0 < 1 + r := by linarith
    -- Key identities
    have hAS_ne : (A^2 + S) ≠ 0 := ne_of_gt hA2_S_pos
    have h1mr_eq : 1 - r = 2 * S / (A^2 + S) := by
      rw [hr_def]; field_simp; ring
    have h1pr_eq : 1 + r = 2 * A^2 / (A^2 + S) := by
      rw [hr_def]; field_simp; ring
    -- The sequence
    refine ⟨fun j => A * (1 - r) * r^j, ?_, ?_, ?_⟩
    · intro j; positivity
    · -- ∑ A(1-r)r^j = A
      have hgeo : HasSum (fun n => r^n) (1 - r)⁻¹ :=
        hasSum_geometric_of_lt_one hr_nonneg hr_lt
      have hh : HasSum (fun j => A * (1-r) * r^j) (A * (1-r) * (1-r)⁻¹) :=
        hgeo.mul_left (A * (1-r))
      have hsimp : A * (1-r) * (1-r)⁻¹ = A := by
        field_simp
      rwa [hsimp] at hh
    · -- ∑ (A(1-r)r^j)^2 = S
      have hr2_nonneg : 0 ≤ r^2 := sq_nonneg _
      have hr2_lt : r^2 < 1 := by
        have : r^2 < 1^2 := by
          apply sq_lt_sq' <;> linarith
        simpa using this
      have h1mr2_pos : 0 < 1 - r^2 := by linarith
      have hgeo2 : HasSum (fun n => (r^2)^n) (1 - r^2)⁻¹ :=
        hasSum_geometric_of_lt_one hr2_nonneg hr2_lt
      have hh2 : HasSum (fun j => A^2 * (1-r)^2 * (r^2)^j)
                       (A^2 * (1-r)^2 * (1-r^2)⁻¹) :=
        hgeo2.mul_left (A^2 * (1-r)^2)
      have hcongr : ∀ j, (A * (1-r) * r^j)^2 = A^2 * (1-r)^2 * (r^2)^j := by
        intro j
        rw [mul_pow, mul_pow, ← pow_mul, mul_comm j 2, pow_mul]
      have hh3 : HasSum (fun j => (A * (1-r) * r^j)^2)
                       (A^2 * (1-r)^2 * (1-r^2)⁻¹) := by
        convert hh2 using 1
        funext j; exact hcongr j
      -- Now show A^2 * (1-r)^2 * (1-r^2)⁻¹ = S
      have hkey : A^2 * (1-r)^2 * (1-r^2)⁻¹ = S := by
        have h1mr2 : 1 - r^2 = (1-r) * (1+r) := by ring
        rw [h1mr2]
        rw [show (1 - r) ^ 2 = (1-r)*(1-r) from by ring]
        rw [h1mr_eq, h1pr_eq]
        have hSne : S ≠ 0 := ne_of_gt hS_pos
        have hA2ne : A^2 ≠ 0 := ne_of_gt hA2pos
        field_simp
      rwa [hkey] at hh3
