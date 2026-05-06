import Mathlib

open Real

/-- Putnam 2015 B1.

  Let `f` be a three times differentiable function (defined on `ℝ` and real-valued)
  such that `f` has at least five distinct real zeros. Prove that
  `f + 6 f' + 12 f'' + 8 f'''` has at least two distinct real zeros. -/
theorem putnam_2015_b1
    (f : ℝ → ℝ)
    (hf : ContDiff ℝ 3 f)
    (Z : Finset ℝ)
    (hZcard : Z.card = 5)
    (hZf : ∀ x ∈ Z, f x = 0) :
    ∃ W : Finset ℝ, W.card = 2 ∧
      ∀ x ∈ W, f x + 6 * deriv f x + 12 * iteratedDeriv 2 f x + 8 * iteratedDeriv 3 f x = 0 := by
  sorry
