import Mathlib

namespace Putnam2018B5

/-- Putnam 2018 B-5. Let `f = (f₁, f₂) : ℝ² → ℝ²` have continuous
positive partial derivatives, with
`(∂f₁/∂x₁)(∂f₂/∂x₂) − (1/4)((∂f₁/∂x₂) + (∂f₂/∂x₁))² > 0`
everywhere. Then `f` is one-to-one. -/
theorem putnam_2018_b5
    (f : ℝ × ℝ → ℝ × ℝ)
    (hf : ContDiff ℝ 1 f)
    (hpos11 : ∀ p, 0 < (fderiv ℝ (fun q => (f q).1) p) (1, 0))
    (hpos12 : ∀ p, 0 < (fderiv ℝ (fun q => (f q).1) p) (0, 1))
    (hpos21 : ∀ p, 0 < (fderiv ℝ (fun q => (f q).2) p) (1, 0))
    (hpos22 : ∀ p, 0 < (fderiv ℝ (fun q => (f q).2) p) (0, 1))
    (hdet : ∀ p,
      (fderiv ℝ (fun q => (f q).1) p) (1, 0) *
        (fderiv ℝ (fun q => (f q).2) p) (0, 1) -
      (1 / 4) *
        ((fderiv ℝ (fun q => (f q).1) p) (0, 1) +
          (fderiv ℝ (fun q => (f q).2) p) (1, 0)) ^ 2 > 0) :
    Function.Injective f := by
  sorry

end Putnam2018B5
