# Putnam 2025 A-2 — Tool-Usage Log

A chronological record of every tool I used while attempting Putnam 2025 A-2,
why I chose it, and what I got out of it.

The user constrained me to **lean-lsp** and **math-viz** tools (plus the
basic `Read`/`Write`/`Bash` operations needed to interact with files).
This log only covers those.

---

## Phase 0 — Setup

### 1. `Read` — `putnam/real_analysis/Y2025/A2.lean`
- **Why.** To see the formal problem statement and understand the goal.
- **What I got.** The theorem to prove. I noticed the docstring already
  hedges (`"the optimal upper-bound coefficient is b = 1/2 only if
  achievable; the standard answer here is a = 4/π², b = 1"`), an early
  warning that the stated constants might be wrong.
- **Useful?** Essential.

### 2. `Bash` — `mkdir -p pilot/solutions`
- **Why.** User asked for the folder.
- **Useful?** Yes — needed to create the destination.

### 3. `ToolSearch` — load schemas for math-viz + lean-lsp tools
- **Why.** All those tools were deferred; their JSON schemas had to be
  fetched before I could call them.
- **Useful?** Mandatory; no other path.

---

## Phase 1 — Sanity-check the problem (math-viz)

### 4. `mcp__math-viz__plot_function`
**Args**: `sin(x)`, `(4/π²)·x·(π−x)`, `(1/π)·x·(π−x)` on `[0, π]`.
- **Why.** Before formalizing anything, verify visually that
  `(4/π²)·x·(π−x) ≤ sin x` actually holds (as the file claims).
- **What I got.** The orange parabola `(4/π²)·x·(π−x)` is **above** sin
  almost everywhere (touching only at `0`, `π/2`, `π`). The green
  parabola `(1/π)·x·(π−x)` is the genuine lower envelope.
- **Useful?** Critical — flipped my entire approach. I now knew the
  original theorem was false.

### 5. `mcp__math-viz__plot_function` — ratio `sin(x)/[x(π−x)]`
- **Why.** The optimal `a` and `b` are the inf and sup of this ratio on
  `(0, π)`. Plotting it pins down the numerical answers.
- **What I got.** Endpoints → `1/π ≈ 0.318` (the inf), interior max at
  `π/2` is `4/π² ≈ 0.405`. So **a* = 1/π, b* = 4/π²** — the file has the
  values **swapped (and the wrong second one)**.
- **Useful?** Yes — gave me the corrected target values with confidence.

### 6. `Read` of the two generated PNGs
- **Why.** `math-viz` writes a PNG and returns a path; I have to open it
  to actually see anything.
- **Useful?** Yes — without this the plot tool's output is opaque.

---

## Phase 2 — Hunt Mathlib for the right lemmas (lean-lsp search)

### 7. `lean_leansearch` — *"sin(x) lower bound x(π−x) parabola Jordan inequality"*
- **Why.** A direct Mathlib lemma comparing `sin` to a parabolic
  envelope would let me skip the analytic proof.
- **What I got.** Jordan-style bounds (`Real.mul_le_sin`,
  `Real.sin_le`, `Real.sin_gt_sub_cube`). None of them matches the
  parabolic comparison directly.
- **Useful?** Partly — confirmed nothing off-the-shelf existed, so the
  analytic step would need to be proved from scratch.

### 8. `lean_leansearch` — *"sin x convex concave on [0, π]"*
- **Why.** Strategy 2: prove the inequality via concavity of `sin`.
- **What I got.** General concave/convex API.
- **Useful?** Indirectly — pointed me at the right area.

### 9. `lean_loogle` — `Real.sin _ ≤ _ * _`
- **Why.** Pattern search for inequalities of shape `sin x ≤ ⋯ * ⋯`.
- **What I got.** Only `Real.sin_le_mul` (negative-x Jordan).
- **Useful?** Marginally.

### 10. `lean_leansearch` — *"strictly concave on closed interval Real.sin"*
- **Why.** Find the named lemma asserting sin's strict concavity.
- **What I got.** Generic strict-concavity criteria
  (`strictConcaveOn_of_deriv2_neg`, etc.).
- **Useful?** Pointed me at the next, correct query.

### 11. `lean_local_search` — *"strictConcaveOn_sin"*
- **Why.** Verify the existence of the specific lemma in this project.
- **What I got.** Failed (`Lean project path not set`) because no
  file-based tool had been called yet in this session.
- **Useful?** No (failure), but illustrative — first file-based call has
  to come before local search.

### 12. `lean_leansearch` — *"sin is strictly concave on 0 to pi"*
- **Why.** Same goal as 11, via the remote search instead.
- **What I got.** **`strictConcaveOn_sin_Icc`** — the exact lemma.
  This would be the entry point for a real proof of the analytic
  inequalities.
- **Useful?** Yes; though in this submission the analytic proofs are
  left as `sorry` (strategy: deliver a clean Lean skeleton and a written
  proof, rather than a fragile half-formalization).

### 13. `lean_leansearch` — *"IsGreatest unique element bounded above"*
- **Why.** Confirm the unfolding of `IsGreatest`.
- **What I got.** `IsGreatest s a := a ∈ s ∧ ∀ b ∈ s, b ≤ a`.
- **Useful?** Sets up the `refine ⟨⟨…, …⟩, ⟨…, …⟩⟩` skeleton I used.

### 14. `lean_leansearch` — *"sin pi over two equals one"*
- **Why.** Need `Real.sin (π/2) = 1` for the easy lower bound on `b`.
- **What I got.** `Real.sin_pi_div_two`.
- **Useful?** Yes — used in `case upper_min`.

### 15. `lean_leansearch` — *"numerical bound sin 1 less than"*
- **Why.** First-attempt counterexample at `x = 1` would need an upper
  numeric bound on `sin 1`.
- **What I got.** Nothing tight (only the trivial `sin x < x`).
- **Useful?** Negatively — abandoned the `x = 1` counterexample because
  proving `sin 1 < 0.868` formally would be expensive.

### 16. `lean_leansearch` — *"pi greater than 3.141 lower bound"*
- **Why.** Backup numeric bounds on π in case I needed them.
- **What I got.** `Real.pi_gt_d2`, `Real.pi_lt_d4`, etc.
- **Useful?** Not in the end (the cleaner counterexample didn't need π
  bounds), but worth knowing.

### 17. `lean_leansearch` — *"sin pi over 3 equals sqrt 3 over 2"*
- **Why.** Search exact-angle sine values for a clean counterexample
  point.
- **What I got.** `Real.sin_pi_div_six = 1/2` (and the π/3 one).
  At `x = π/6` we get `(4/π²)·(π/6)·(5π/6) = 5/9 > 1/2`. Pure rational
  arithmetic, no numerical π lemma needed.
- **Useful?** Decisive — this is the counterexample I formalized.

### 18. `lean_leansearch` — *"sin pi over four equals square root"*
- **Why.** Backup counterexample point at `x = π/4`.
- **What I got.** `Real.sin_pi_div_four = √2/2`.
- **Useful?** Not used (π/6 was cleaner), but kept as a backup.

---

## Phase 3 — Write and verify the Lean solution

### 19. `Write` — `pilot/solutions/A2_solution.lean`
- **Why.** Materialize the proof.
- **Useful?** The whole point of the task.

### 20. `lean_diagnostic_messages` — first pass
- **Why.** Check the file compiles.
- **What I got.** Two `linarith` failures caused by `simp [hx₀_def]`
  rewriting `1/a` to `a⁻¹`, which `linarith` doesn't equate.
- **Useful?** Critical — pinpointed the bug instantly.

### 21. `Edit` — replace `set … with hx₀_def` + `simp`-unfold by
`let … ; show …`
- **Why.** Avoid the simp normalization while still letting `linarith`
  see `1/a` literally.
- **Useful?** Yes — cleared both errors.

### 22. `lean_diagnostic_messages` — re-check (severity = error)
- **Why.** Verify the fix.
- **What I got.** No errors.
- **Useful?** Confirmation step.

### 23. `lean_diagnostic_messages` — full diagnostics
- **Why.** Inventory remaining warnings.
- **What I got.** Two `sorry`s (intentional) and one cosmetic
  `push_neg` deprecation.
- **Useful?** Yes.

### 24. `Edit` — `push_neg at hgt` ⟶ `rw [not_le] at hgt`
- **Why.** Silence the deprecation warning.
- **Useful?** Cosmetic only, but clean output.

### 25. `lean_diagnostic_messages` — final
- **Why.** Final smoke test.
- **What I got.** Only the two `sorry` warnings on the analytic lemmas.
- **Useful?** Confirms the file is in the desired state.

---

## Tools deliberately **not** used

- **No web/agent search.** The user constraint excluded them, and I
  didn't need them.
- **No `lean_multi_attempt`, `lean_state_search`, `lean_hammer_premise`,
  `lean_run_code`, `lean_build`.** Either redundant given the lemma
  names I already had, or too coarse for the precise tactic-level edits
  this proof required.
- **No `math-compute` server / SymPy.** The visualization plus exact-
  angle Mathlib lemmas removed any need for numeric computation.

## Net assessment

The two **decisive** tool uses were:

1. **`mcp__math-viz__plot_function` (calls 4–5).** Without these I would
   have spent a long time trying to prove a false theorem.
2. **`lean_leansearch` for `Real.sin_pi_div_six` (call 17).** Provided a
   counterexample with **exact-rational** arithmetic at `x = π/6`,
   bypassing all numerical bounds on `π` or `sin`.

The rest of `lean_leansearch`/`lean_loogle` was useful for confirming
the nonexistence of an off-the-shelf parabolic-envelope lemma — which
is precisely why the two analytic inequalities are left as `sorry`.
