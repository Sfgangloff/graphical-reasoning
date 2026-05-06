import Mathlib

open Filter Topology

noncomputable def putnam_2000_a1_solution : ℝ → Set ℝ := fun A => Set.Ioo 0 (A^2)

theorem putnam_2000_a1 (A : ℝ) (hA : A > 0) :
    {S : ℝ | ∃ x : ℕ → ℝ, (∀ j, x j > 0) ∧ HasSum x A ∧ HasSum (fun j => (x j)^2) S} =
      putnam_2000_a1_solution A := by
  ext S
  simp only [Set.mem_setOf_eq, putnam_2000_a1_solution, Set.mem_Ioo]
  constructor
  · rintro ⟨x, hxpos, hxsum, hx2sum⟩
    -- Each x j ≤ A
    have hxle : ∀ j, x j ≤ A := by
      intro j
      have h1 : x j = ∑ i ∈ {j}, x i := by simp
      rw [h1]
      exact sum_le_hasSum {j} (fun i _ => le_of_lt (hxpos i)) hxsum
    have hxlt : ∀ j, x j < A := by
      intro j
      -- x j + x (j+1) ≤ A and x (j+1) > 0
      have h2 : x j + x (j+1) ≤ A := by
        have h1 : x j + x (j+1) = ∑ i ∈ {j, j+1}, x i := by
          rw [Finset.sum_pair (by omega)]
        rw [h1]
        exact sum_le_hasSum {j, j+1} (fun i _ => le_of_lt (hxpos i)) hxsum
      linarith [hxpos (j+1)]
    refine ⟨?_, ?_⟩
    · -- 0 < S: x 0 ^ 2 ≤ S
      have h0 : (x 0)^2 ≤ S := by
        have h1 : (x 0)^2 = ∑ i ∈ {0}, (x i)^2 := by simp
        rw [h1]
        exact sum_le_hasSum {0} (fun i _ => sq_nonneg _) hx2sum
      have := hxpos 0
      nlinarith [sq_nonneg (x 0), hxpos 0]
    · -- S < A^2
      -- We have x j ^ 2 ≤ A * x j for all j (since x j ≤ A and x j ≥ 0)
      -- So S = ∑ x j ^ 2 ≤ A * ∑ x j = A^2
      -- Strict because x 0 ^ 2 < A * x 0 (since x 0 < A and x 0 > 0)
      have hAx : HasSum (fun j => A * x j) (A * A) := hxsum.mul_left A
      have hxsum2 : HasSum (fun j => A * x j - (x j)^2) (A * A - S) :=
        hAx.sub hx2sum
      have hxnn : ∀ j, 0 ≤ A * x j - (x j)^2 := by
        intro j
        have := hxpos j
        have := hxle j
        nlinarith
      have hxpos0 : 0 < A * x 0 - (x 0)^2 := by
        have h1 := hxpos 0
        have h2 := hxlt 0
        nlinarith
      have hsum_pos : 0 < A * A - S := by
        have h1 : A * x 0 - (x 0)^2 ≤ A * A - S := by
          have := sum_le_hasSum {0} (fun i _ => hxnn i) hxsum2
          simpa using this
        linarith
      nlinarith [sq_nonneg A]
  · rintro ⟨hS0, hSA⟩
    -- Construct x j = c * r ^ j with c = A * (1 - r), where r = (A^2 - S) / (A^2 + S)
    set r := (A^2 - S) / (A^2 + S) with hr_def
    have hA2pos : 0 < A^2 := by positivity
    have hsum_pos : 0 < A^2 + S := by linarith
    have hr_pos : 0 < r := by
      apply div_pos <;> linarith
    have hr_lt_one : r < 1 := by
      rw [hr_def, div_lt_one hsum_pos]
      linarith
    set c := A * (1 - r) with hc_def
    have hc_pos : 0 < c := by
      apply mul_pos hA
      linarith
    refine ⟨fun j => c * r^j, ?_, ?_, ?_⟩
    · intro j
      apply mul_pos hc_pos
      exact pow_pos hr_pos j
    · -- HasSum (fun j => c * r^j) A
      have hr_abs : |r| < 1 := by
        rw [abs_of_pos hr_pos]
        exact hr_lt_one
      have hgeom : HasSum (fun j => r^j) (1 / (1 - r)) := by
        have := hasSum_geometric_of_lt_one (le_of_lt hr_pos) hr_lt_one
        convert this using 1
        field_simp
      have h1 : HasSum (fun j => c * r^j) (c * (1 / (1 - r))) := hgeom.mul_left c
      convert h1 using 1
      have h1mr_pos : 0 < 1 - r := by linarith
      rw [hc_def, mul_assoc, mul_one_div, div_self (ne_of_gt h1mr_pos), mul_one]
    · -- HasSum (fun j => (c * r^j)^2) S
      have hr2_pos : 0 < r^2 := by positivity
      have hr2_lt : r^2 < 1 := by
        have : r^2 < 1^2 := by
          apply sq_lt_sq' <;> nlinarith
        simpa using this
      have hgeom2 : HasSum (fun j => (r^2)^j) (1 / (1 - r^2)) := by
        have := hasSum_geometric_of_lt_one (le_of_lt hr2_pos) hr2_lt
        convert this using 1
        field_simp
      have h1 : HasSum (fun j => c^2 * (r^2)^j) (c^2 * (1 / (1 - r^2))) :=
        hgeom2.mul_left (c^2)
      have heq : (fun j => (c * r^j)^2) = (fun j => c^2 * (r^2)^j) := by
        funext j
        ring
      rw [heq]
      convert h1 using 1
      -- c^2 / (1 - r^2) = S
      have h1mr_pos : 0 < 1 - r := by linarith
      have h1mr2_pos : 0 < 1 - r^2 := by nlinarith
      have h1pr_pos : 0 < 1 + r := by linarith
      rw [hc_def]
      have hfact : 1 - r^2 = (1 - r) * (1 + r) := by ring
      rw [hfact]
      field_simp
      -- Need to show A^2 * (1 - r)^2 / ((1-r) * (1+r)) = S
      -- Simplify to A^2 * (1 - r) / (1 + r) = S
      -- (1 - r) / (1 + r) = (1 - (A^2-S)/(A^2+S)) / (1 + (A^2-S)/(A^2+S))
      --                    = ((A^2+S - A^2 + S)/(A^2+S)) / ((A^2+S+A^2-S)/(A^2+S))
      --                    = (2S) / (2A^2) = S / A^2
      -- So A^2 * S / A^2 = S ✓
      rw [hr_def]
      field_simp
      ring
