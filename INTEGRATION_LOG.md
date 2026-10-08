# Git Lab 02 – Branch Integration Log (release-plan)

Release captain's record of how the contractor branches were audited, planned and
integrated into `release-plan`. Base: `dev` @ `feat: add legacy grade calculator`.

Environment: `git version 2.43.0`, `Python 3.13`.
The starting branches can be recreated with `./create_grade_calculator_repo.sh [dir]`.

## 1. Branch audit (Step 2)

Commands used for every branch:

```bash
git log --oneline --graph dev..<branch>
git diff --stat dev...<branch>
git diff dev...<branch>
git show <branch>:grade_calculator.py > /tmp/gc.py && python /tmp/gc.py
```

Baseline (`dev`) output — note the bug: Diana shows **90.0** but gets **B**,
because the grade is computed from `int(average)` (89.975 → 89).

```
Alice: 89.8 (B)   Bob: 72.5 (C)   Charlie: 60.0 (D)   Diana: 90.0 (B)   Evan: 80.0 (C)
```

| Branch | Claims to solve | Files / changes | Runtime result | Risks / style | Verdict |
|---|---|---|---|---|---|
| `feature/weighted-average` (2 commits) | Final exam should count more than homework | `grade_calculator.py`: `WEIGHTS` dict, `calculate_weighted_average()` with input checks; `main()` uses it | Runs. Alice 88.7 B, Diana 90.1 A, Evan 80.0 **C** (truncation bug still there) | Relies on dict order matching score order (homework, quiz, midterm, final). Same `snake_case` style as dev. | **Ship** (merge) |
| `feature/detailed-output` (2 commits) | Richer report: table with scores, low, high | Rewrites `format_report()` (new signature `name, scores, avg, grade`), new header/footer in `main()`, renames `average`→`avg` | Runs, nice table + student count | Different style: camelCase `scoreList`, `%` formatting, single quotes. Touches the same `main()` lines as weighted-average → **conflict expected** | **Ship** (merge, normalise style) |
| `fix/rounding-bug` (2 commits) | Grade must match the displayed average | Commit 1: `int(average)` → `round(average, 1)`. Commit 2: leftover `DEBUG raw average` print | Fix works (Diana → A) but output is polluted by DEBUG lines | Debug commit must not ship. Line overlaps with weighted/detailed changes in `main()` → **conflict expected** | **Ship commit 1 only** (cherry-pick), discard commit 2 |
| `feature/strict-grading` (1 commit) | Stricter grade scale + input validation | New `validate_scores()`, thresholds raised to A≥93/B≥85/C≥77/D≥70 | **Crashes**: `ValueError: invalid score: 100` — `0 <= score < 100` rejects a perfect score | Policy change (thresholds) without registrar sign-off; off-by-one validation bug | **Review → likely reject**. Merge as an experiment only, revert if it regresses |
| `feature/plus-minus-grades` (2 commits) | `B+` / `B-` style grades | `get_letter_grade()` returns letter + `get_modifier()`; header prints the scale | Runs. Diana shows 90.0 but `B+` (inherits the truncation bug from dev) | Touches the header lines that detailed-output rewrote → **conflict expected**. Local, unshared branch → safe to rebase | **Ship via rebase** |

## 2. Integration plan (Step 3) — written before executing

| Order | Branch | Action | Why | Expected conflicts |
|---|---|---|---|---|
| 1 | `feature/weighted-average` | `git merge --no-ff` | Core calculation change; everything else displays its result. `--no-ff` keeps a merge commit as an audit point that can be reverted as a unit. | None (dev is unchanged) |
| 2 | `feature/detailed-output` | `git merge --no-ff` | Display layer on top of the new calculation | `main()`: `average = calculate_weighted_average(...)` vs `avg = calculate_average(...)` |
| 3 | `fix/rounding-bug` | `git cherry-pick -n` of the debug commit + `git restore` (to discard it), then `git cherry-pick -x` of the fix commit only | Branch mixes a good fix with debug noise; merging would bring the noise in | `grade = get_letter_grade(...)` line in `main()` |
| 4 | `feature/strict-grading` | `git merge --no-ff`, validate, `git revert -m 1` if it regresses | Validation idea is valuable but the runtime run already failed on the branch; prove it on the integrated code, keep a revertable merge commit | Loop body in `main()` |
| 5 | `feature/plus-minus-grades` | `git rebase release-plan`, then `git merge --ff-only` | Small, private branch: replaying it on top of the release gives linear history with no extra merge commit | Header lines in `main()` |
| — | `dev`, `main` | untouched | `release-plan` is reviewed separately; it is **not** merged into `main` | — |

Recovery plan if anything regresses:

* bad merge commit already in history → `git revert -m 1 <merge-sha>` (safe for shared branches)
* merge in progress with messy conflicts → `git merge --abort` / `git rebase --abort` / `git cherry-pick --abort`
* unwanted uncommitted changes → `git restore --staged --worktree <file>`
* local experiment only → `git reset --hard ORIG_HEAD` (never on pushed commits)

Pass/fail for the CLI (Step 5): **pass** = `python grade_calculator.py` exits 0, no
traceback, no debug lines, every student row present, the grade matches the displayed
average under the active scale. **Fail** = traceback, non-zero exit, stray debug output,
or a grade that contradicts the shown average.
