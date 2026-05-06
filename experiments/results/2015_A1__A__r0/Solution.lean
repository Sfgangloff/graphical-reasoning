import Mathlib

open Real MeasureTheory intervalIntegral

/--
Putnam 2015 A1.  Let $A$ and $B$ be points on the same branch of the hyperbola
$xy=1$, and let $P$ lie between $A$ and $B$ on this hyperbola so that the
triangle $APB$ has maximum area.  Then the region between chord $AP$ and the
hyperbola has the same area as the region between chord $PB$ and the hyperbola.

We formalize the (positive‐branch) case with $0<a<p<b$ where $A=(a,1/a)$,
$P=(p,1/p)$, $B=(b,1/b)$.  The maximality of the (signed) triangle area is
encoded by `hmax`.
-/
theorem putnam_2015_a1
    (a p b : ℝ) (h1 : 0 < a) (h2 : a < p) (h3 : p < b)
    (hmax : ∀ q : ℝ, a < q → q < b →
      a * (1/q - 1/b) + q * (1/b - 1/a) + b * (1/a - 1/q) ≤
      a * (1/p - 1/b) + p * (1/b - 1/a) + b * (1/a - 1/p))
    : (∫ x in a..p, ((a + p - x)/(a*p) - 1/x)) =
      (∫ x in p..b, ((p + b - x)/(p*b) - 1/x)) := by
  -- Positivity facts.
  have hp : 0 < p := h1.trans h2
  have hb : 0 < b := hp.trans h3
  have hab : 0 < a * b := mul_pos h1 hb
  have hap : 0 < a * p := mul_pos h1 hp
  have hpb : 0 < p * b := mul_pos hp hb
  have ha' : a ≠ 0 := ne_of_gt h1
  have hp' : p ≠ 0 := ne_of_gt hp
  have hb' : b ≠ 0 := ne_of_gt hb
  have hab' : a*b ≠ 0 := ne_of_gt hab
  have h_ba_pos : 0 < b - a := by linarith
  -- Step 1: derive p^2 = a*b from maximality.
  have hp2 : p * p = a * b := by
    set s : ℝ := Real.sqrt (a*b) with hs_def
    have hs_pos : 0 < s := Real.sqrt_pos.mpr hab
    have hs_sq : s * s = a*b := Real.mul_self_sqrt hab.le
    -- a < s < b.
    have h_a_lt_s : a < s := by
      have : a*a < a*b := by nlinarith
      have h1 : a*a = a*a := rfl
      nlinarith [Real.sq_sqrt hab.le, Real.sqrt_nonneg (a*b),
        Real.sqrt_lt_sqrt (sq_nonneg a) (by nlinarith : a^2 < a*b)]
    have h_s_lt_b : s < b := by
      nlinarith [Real.sq_sqrt hab.le, Real.sqrt_nonneg (a*b),
        Real.sqrt_lt_sqrt hab.le (by nlinarith : a*b < b^2)]
    have hmax_s := hmax s h_a_lt_s h_s_lt_b
    -- Rewrite using factorization.
    have eq_factor : ∀ q : ℝ, q ≠ 0 →
        a*(1/q - 1/b) + q*(1/b - 1/a) + b*(1/a - 1/q)
        = (b - a) * ((a+b)/(a*b) - 1/q - q/(a*b)) := by
      intro q hq
      field_simp
      ring
    have key_ineq : 1/p + p/(a*b) ≤ 1/s + s/(a*b) := by
      rw [eq_factor s (ne_of_gt hs_pos), eq_factor p hp'] at hmax_s
      have := (mul_le_mul_left h_ba_pos).mp hmax_s
      linarith
    -- 1/s + s/(ab) = 2/s.
    have eq_s : 1/s + s/(a*b) = 2/s := by
      have : s/(a*b) = 1/s := by
        rw [← hs_sq]; field_simp
      rw [this]; ring
    rw [eq_s] at key_ineq
    -- AM-GM: 1/p + p/(ab) ≥ 2/s.
    have amgm : (2:ℝ)/s ≤ 1/p + p/(a*b) := by
      have hineq : 0 ≤ (1/p - p/(a*b))^2 := sq_nonneg _
      have h_pos : 0 < 1/p + p/(a*b) := by positivity
      have h_2s_pos : 0 < (2:ℝ)/s := by positivity
      have h_prod : (1/p) * (p/(a*b)) = 1/(a*b) := by field_simp
      have sq_lhs : (1/p + p/(a*b))^2 = (1/p - p/(a*b))^2 + 4/(a*b) := by
        have : (1/p + p/(a*b))^2 = (1/p - p/(a*b))^2 + 4*((1/p)*(p/(a*b))) := by ring
        rw [this, h_prod]
      have sq_rhs : ((2:ℝ)/s)^2 = 4/(a*b) := by
        rw [div_pow, ← hs_sq]
        ring_nf
        field_simp
        ring
      have sq_le : ((2:ℝ)/s)^2 ≤ (1/p + p/(a*b))^2 := by
        rw [sq_rhs, sq_lhs]; linarith
      exact (sq_le_sq' (by linarith [h_pos, h_2s_pos]) sq_le).trans_eq (abs_of_pos h_pos)
        |>.le |>.trans (le_refl _)
        |> (fun _ => by nlinarith [sq_nonneg (1/p + p/(a*b) - 2/s),
              sq_nonneg (1/p + p/(a*b) + 2/s), sq_le, h_pos.le, h_2s_pos.le])
    have eq : 1/p + p/(a*b) = 2/s := le_antisymm key_ineq amgm
    -- Equality in AM-GM means (1/p - p/(ab))^2 = 0, so 1/p = p/(ab), i.e., p^2 = ab.
    have h_prod : (1/p) * (p/(a*b)) = 1/(a*b) := by field_simp
    have sq_eq : (1/p - p/(a*b))^2 = 0 := by
      have e1 : (1/p + p/(a*b))^2 = (1/p - p/(a*b))^2 + 4*((1/p)*(p/(a*b))) := by ring
      have e2 : ((2:ℝ)/s)^2 = 4/(a*b) := by
        rw [div_pow, ← hs_sq]; field_simp; ring
      have : (1/p + p/(a*b))^2 = 4/(a*b) := by rw [eq, e2]
      have : (1/p - p/(a*b))^2 + 4*((1/p)*(p/(a*b))) = 4/(a*b) := by rw [← e1]; exact this
      rw [h_prod] at this
      linarith
    have : 1/p - p/(a*b) = 0 := by
      have := pow_eq_zero_iff (n := 2) (by norm_num : 2 ≠ 0) |>.mp sq_eq
      exact this
    have : 1/p = p/(a*b) := by linarith
    field_simp at this
    linarith
  -- Step 2: Compute the integrals and show equality.
  -- ∫_a^p ((a+p-x)/(a*p) - 1/x) dx = (p-a)^2/(2*a*p) ... actually let me re-derive
  -- ∫_a^p (a+p-x)/(a*p) dx = ((a+p)*x - x^2/2)/(a*p) |_a^p
  --   = ((a+p)(p-a) - (p^2-a^2)/2)/(a*p)
  --   = ((p-a)(a+p) - (p-a)(p+a)/2)/(a*p)
  --   = (p-a)(p+a)/2 / (a*p) = (p^2 - a^2)/(2*a*p)
  -- ∫_a^p 1/x dx = log p - log a
  -- So LHS = (p^2 - a^2)/(2*a*p) - (log p - log a)
  -- RHS = (b^2 - p^2)/(2*p*b) - (log b - log p)
  -- With p*p = a*b, we get LHS = RHS as computed.
  have integral_LHS : (∫ x in a..p, ((a + p - x)/(a*p) - 1/x)) =
      (p^2 - a^2)/(2*a*p) - (Real.log p - Real.log a) := by
    have h_ap_ne : a*p ≠ 0 := ne_of_gt hap
    have step1 : (∫ x in a..p, ((a + p - x)/(a*p))) =
        (p^2 - a^2)/(2*a*p) := by
      have eq : (fun x : ℝ => (a + p - x)/(a*p))
              = (fun x => (a+p)/(a*p) - x/(a*p)) := by
        funext x; field_simp; ring
      rw [eq]
      rw [intervalIntegral.integral_sub
        (by exact intervalIntegrable_const)
        ((continuous_id.div_const (a*p)).intervalIntegrable _ _)]
      rw [intervalIntegral.integral_const]
      rw [show (fun x : ℝ => x/(a*p)) = (fun x => (1/(a*p)) * x) by
            funext x; ring]
      rw [intervalIntegral.integral_const_mul]
      rw [integral_id]
      field_simp
      ring
    have step2 : (∫ x in a..p, (1:ℝ)/x) = Real.log p - Real.log a := by
      rw [show (fun x : ℝ => 1/x) = (fun x => x⁻¹) by funext x; rw [one_div]]
      rw [integral_inv (by simp [Set.uIcc_of_le h2.le]; constructor <;> intro hx <;> linarith)]
      rw [Real.log_div hp' ha']
    rw [intervalIntegral.integral_sub
      (((continuous_const.sub continuous_id).div_const (a*p)).intervalIntegrable _ _)
      _]
    · rw [step1, step2]
    · -- 1/x is integrable on [a,p] since 0 < a.
      apply ContinuousOn.intervalIntegrable
      apply ContinuousOn.div continuousOn_const continuousOn_id
      intro x hx
      rcases le_or_lt a p with hap_le | hap_lt
      · simp [Set.uIcc_of_le hap_le] at hx
        linarith [hx.1]
      · linarith
  have integral_RHS : (∫ x in p..b, ((p + b - x)/(p*b) - 1/x)) =
      (b^2 - p^2)/(2*p*b) - (Real.log b - Real.log p) := by
    have h_pb_ne : p*b ≠ 0 := ne_of_gt hpb
    have step1 : (∫ x in p..b, ((p + b - x)/(p*b))) =
        (b^2 - p^2)/(2*p*b) := by
      have eq : (fun x : ℝ => (p + b - x)/(p*b))
              = (fun x => (p+b)/(p*b) - x/(p*b)) := by
        funext x; field_simp; ring
      rw [eq]
      rw [intervalIntegral.integral_sub
        (by exact intervalIntegrable_const)
        ((continuous_id.div_const (p*b)).intervalIntegrable _ _)]
      rw [intervalIntegral.integral_const]
      rw [show (fun x : ℝ => x/(p*b)) = (fun x => (1/(p*b)) * x) by
            funext x; ring]
      rw [intervalIntegral.integral_const_mul]
      rw [integral_id]
      field_simp
      ring
    have step2 : (∫ x in p..b, (1:ℝ)/x) = Real.log b - Real.log p := by
      rw [show (fun x : ℝ => 1/x) = (fun x => x⁻¹) by funext x; rw [one_div]]
      rw [integral_inv (by simp [Set.uIcc_of_le h3.le]; constructor <;> intro hx <;> linarith)]
      rw [Real.log_div hb' hp']
    rw [intervalIntegral.integral_sub
      (((continuous_const.sub continuous_id).div_const (p*b)).intervalIntegrable _ _)
      _]
    · rw [step1, step2]
    · apply ContinuousOn.intervalIntegrable
      apply ContinuousOn.div continuousOn_const continuousOn_id
      intro x hx
      rcases le_or_lt p b with hpb_le | hpb_lt
      · simp [Set.uIcc_of_le hpb_le] at hx
        linarith [hx.1]
      · linarith
  rw [integral_LHS, integral_RHS]
  -- Now use p*p = a*b to conclude.
  -- log(p) - log(a) = log(b) - log(p)  iff  log(p^2) = log(a*b)  iff  p^2 = a*b ✓
  have log_eq : Real.log p - Real.log a = Real.log b - Real.log p := by
    have : 2 * Real.log p = Real.log a + Real.log b := by
      have h1 : Real.log (p*p) = 2 * Real.log p := by
        rw [Real.log_mul hp' hp']; ring
      have h2 : Real.log (a*b) = Real.log a + Real.log b := Real.log_mul ha' hb'
      rw [← h1, hp2, h2]
    linarith
  have arith_eq : (p^2 - a^2)/(2*a*p) = (b^2 - p^2)/(2*p*b) := by
    have hp2' : p^2 = a*b := by rw [sq]; exact hp2
    rw [hp2']
    field_simp
    ring
  linarith
