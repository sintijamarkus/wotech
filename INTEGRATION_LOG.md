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

## 3. Execution log (Step 4) — plan vs. reality

| # | Command(s) | Predicted | Actual | Resolution |
|---|---|---|---|---|
| 1 | `git merge --no-ff feature/weighted-average` | no conflict | no conflict | — |
| 2 | `git merge --no-ff feature/detailed-output` | conflict in `main()` | ✅ conflict in `main()` loop (`average = calculate_weighted_average` vs `avg = calculate_average`, new `format_report` signature) | kept weighted calc + detailed table, converted contractor style to snake_case/f-strings |
| 3a | `git cherry-pick -n fix/rounding-bug` (debug commit) → `git restore --source=HEAD --staged --worktree grade_calculator.py` → `git cherry-pick --quit` | debug commit unwanted | conflicted *and* only adds `DEBUG` prints | discarded, nothing committed |
| 3b | `git cherry-pick -x fix/rounding-bug~1` | conflict on the `grade =` line | ✅ conflict | applied `round(average, 1)` to the weighted/detailed loop |
| 4 | `git merge --no-ff feature/strict-grading` | conflict in loop body | ✅ conflict in loop body **and** next to `calculate_weighted_average()` (not predicted) | kept both functions; runtime then failed: `ValueError: invalid score: 100` |
| 4b | `git revert -m 1 <strict-merge>` | revert if it regresses | regression confirmed | reverted; `git diff HEAD~2 HEAD` is empty → exact restore |
| 5 | `git checkout feature/plus-minus-grades && git rebase release-plan` | conflict in header | ✅ commit 2 conflicted (old `Grade Report` banner no longer exists); commit 1 applied cleanly | print scale line above new table header, `git rebase --continue` |
| 5b | `git checkout release-plan && git merge --ff-only feature/plus-minus-grades` | fast-forward | fast-forward | linear history, no merge commit |

## 4. Validation (Step 5)

`python grade_calculator.py` was run after every step:

| After step | Alice | Bob | Charlie | Diana | Evan | Exit | Result |
|---|---|---|---|---|---|---|---|
| `dev` baseline | 89.8 B | 72.5 C | 60.0 D | 90.0 **B** ✗ | 80.0 C | 0 | rounding bug |
| 1 weighted-average | 88.7 B | 72.5 C | 61.1 D | 90.1 A | 80.0 **C** ✗ | 0 | pass (bug still present) |
| 2 detailed-output | 88.7 B | 72.5 C | 61.1 D | 90.1 A | 80.0 C ✗ | 0 | pass, table + footer |
| 3 rounding fix | 88.7 B | 72.5 C | 61.1 D | 90.1 A | 80.0 **B** ✓ | 0 | pass, no DEBUG lines |
| 4 strict-grading | — | — | — | — | — | **1** | **FAIL** `ValueError: invalid score: 100` |
| 4b revert | 88.7 B | 72.5 C | 61.1 D | 90.1 A | 80.0 B | 0 | pass (identical to step 3) |
| 5 plus-minus (final) | 88.7 B+ | 72.5 C- | 61.1 D- | 90.1 A- | 80.0 B- | 0 | **pass** |

Final `release-plan` output:

```
Scale: A/B/C/D with +/- modifiers, F has no modifier
Name     Scores                   Low  High  Average  Grade
-----------------------------------------------------------
Alice    92, 88, 100, 79           79   100     88.7     B+
Bob      75, 64, 81, 70            64    81     72.5     C-
Charlie  58, 62, 49, 71            49    71     61.1     D-
Diana    89.5, 90, 89.4, 91      89.4    91     90.1     A-
Evan     80, 79.8, 80, 80        79.8    80     80.0     B-
-----------------------------------------------------------
Students: 5
```

## 5. Final status (Step 6)

| Branch | Outcome |
|---|---|
| `feature/weighted-average` | ✅ shipped (merge commit) |
| `feature/detailed-output` | ✅ shipped (merge commit, conflict resolved, style normalised) |
| `fix/rounding-bug` | ✅ fix shipped via `cherry-pick -x`; debug commit discarded |
| `feature/strict-grading` | ❌ rejected — merged, failed validation, reverted with `git revert -m 1`; branch left isolated |
| `feature/plus-minus-grades` | ✅ shipped via rebase + fast-forward (linear history) |

`release-plan` is **not** merged into `main`; reviewers check it out directly:

```bash
git fetch origin && git checkout release-plan && python grade_calculator.py
git log --oneline --graph dev..release-plan
```
