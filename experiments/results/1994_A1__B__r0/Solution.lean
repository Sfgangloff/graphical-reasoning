import Mathlib

open Finset BigOperators Filter Topology

private lemma sum_pair_range (f : ℕ → ℝ) (N : ℕ) :
    ∑ n ∈ range N, (f (2*n) + f (2*n+1)) = ∑ m ∈ range (2*N), f m := by
  induction N with
  | zero => simp
  | succ N ih =>
    rw [sum_range_succ, ih]
    have h : 2 * (N + 1) = (2 * N + 1) + 1 := by ring
    rw [h, sum_range_succ, sum_range_succ]
    ring

theorem putnam_1994_a1 (a : ℕ → ℝ)
    (ha : ∀ n ≥ 1, 0 < a n ∧ a n ≤ a (2*n) + a (2*n+1)) :
    ¬ Summable a := by
  intro hsum
  have hpos1 : 0 < a 1 := (ha 1 le_rfl).1
  have hineq : ∀ n ≥ 1, a n ≤ a (2*n) + a (2*n+1) := fun n hn => (ha n hn).2

  set V : ℕ → ℝ := fun k => ∑ n ∈ range (2^k), a n with hV_def

  have hpow1 : ∀ k, 1 ≤ 2^k := fun k => Nat.one_le_pow k 2 (by norm_num)

  have hVstep : ∀ k, V k + a 1 ≤ V (k+1) := by
    intro k
    show ∑ n ∈ range (2^k), a n + a 1 ≤ ∑ n ∈ range (2^(k+1)), a n
    have hPow : 2^(k+1) = 2 * 2^k := by ring
    rw [hPow, ← sum_pair_range a (2^k)]
    have hsplit : ∀ (g : ℕ → ℝ),
        ∑ n ∈ range (2^k), g n = g 0 + ∑ n ∈ Ico 1 (2^k), g n := by
      intro g
      have hset : range (2^k) = insert 0 (Ico 1 (2^k)) := by
        ext x
        simp only [mem_range, mem_insert, mem_Ico]
        constructor
        · intro hx
          rcases Nat.eq_zero_or_pos x with hx0 | hx0
          · left; exact hx0
          · right; exact ⟨hx0, hx⟩
        · rintro (rfl | ⟨h1, h2⟩)
          · exact hpow1 k
          · exact h2
      rw [hset, sum_insert (by simp)]
    rw [hsplit a, hsplit (fun n => a (2*n) + a (2*n+1))]
    simp only [Nat.mul_zero, zero_add]
    have hineq_sum : ∑ n ∈ Ico 1 (2^k), a n ≤
        ∑ n ∈ Ico 1 (2^k), (a (2*n) + a (2*n+1)) := by
      apply sum_le_sum
      intro n hn
      rw [mem_Ico] at hn
      exact hineq n hn.1
    linarith

  have hV0 : V 0 = a 0 := by
    show ∑ n ∈ range (2^0), a n = a 0
    simp

  have hVbound : ∀ k : ℕ, a 0 + (k : ℝ) * a 1 ≤ V k := by
    intro k
    induction k with
    | zero => simp [hV0]
    | succ k ih =>
      have hstep := hVstep k
      have hcast : ((k+1 : ℕ) : ℝ) = (k : ℝ) + 1 := by push_cast; ring
      rw [hcast]
      linarith

  have htend : Tendsto (fun N => ∑ n ∈ range N, a n) atTop (𝓝 (∑' n, a n)) :=
    hsum.hasSum.tendsto_sum_nat

  have hpowtend : Tendsto (fun k : ℕ => (2:ℕ)^k) atTop atTop := by
    rw [tendsto_atTop_atTop]
    intro b
    refine ⟨b, fun n hn => ?_⟩
    exact hn.trans (Nat.lt_two_pow_self).le

  have hVtend : Tendsto V atTop (𝓝 (∑' n, a n)) := htend.comp hpowtend

  have hbdd : BddAbove (Set.range V) := hVtend.bddAbove_range

  obtain ⟨M, hM⟩ := hbdd

  obtain ⟨k, hk⟩ := exists_nat_gt ((M - a 0) / a 1)
  have h1 : a 0 + (k : ℝ) * a 1 ≤ M := (hVbound k).trans (hM ⟨k, rfl⟩)
  have h2 : (k : ℝ) * a 1 ≤ M - a 0 := by linarith
  have h3 : (k : ℝ) ≤ (M - a 0) / a 1 := (le_div_iff₀ hpos1).mpr (by linarith)
  linarith
