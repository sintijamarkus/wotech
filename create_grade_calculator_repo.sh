#!/usr/bin/env bash
# Rebuilds the Git Lab 02 starting point: a legacy grade calculator on `dev`
# plus the competing contractor branches.
#
# Usage: ./create_grade_calculator_repo.sh [target-dir]
#   target-dir defaults to ./grade-calculator-practice
#   If target-dir is already a git repo, `dev` is branched from its HEAD.
set -euo pipefail

TARGET="${1:-grade-calculator-practice}"
mkdir -p "$TARGET"
cd "$TARGET"
if [ ! -d .git ]; then
    git init -q
    git commit -q --allow-empty -m "chore: initialize repository"
fi

for b in dev release-plan feature/strict-grading feature/weighted-average \
         feature/detailed-output feature/plus-minus-grades fix/rounding-bug; do
    if git show-ref --verify --quiet "refs/heads/$b"; then
        echo "Branch $b already exists - aborting to avoid clobbering work." >&2
        exit 1
    fi
done

commit() { git add -A grade_calculator.py; git commit -q -m "$1"; }

# ---------------------------------------------------------------- dev
git checkout -q -b dev
cat > grade_calculator.py <<'EOF'
#!/usr/bin/env python3
"""
Legacy grade calculator for the registrar's office.

Each student has four scores: homework, quiz, midterm, final.
Run with:  python grade_calculator.py
"""

STUDENTS = {
    "Alice": [92, 88, 100, 79],
    "Bob": [75, 64, 81, 70],
    "Charlie": [58, 62, 49, 71],
    "Diana": [89.5, 90, 89.4, 91],
    "Evan": [80, 79.8, 80, 80],
}


def calculate_average(scores):
    """Return the arithmetic mean of a list of scores."""
    return sum(scores) / len(scores)


def get_letter_grade(average):
    """Map a numeric average to a letter grade."""
    if average >= 90:
        return "A"
    elif average >= 80:
        return "B"
    elif average >= 70:
        return "C"
    elif average >= 60:
        return "D"
    else:
        return "F"


def format_report(name, average, grade):
    """Build a one-line report for a student."""
    return f"{name}: {average:.1f} ({grade})"


def main():
    print("Grade Report")
    print("------------")
    for name, scores in STUDENTS.items():
        average = calculate_average(scores)
        grade = get_letter_grade(int(average))
        print(format_report(name, average, grade))


if __name__ == "__main__":
    main()
EOF
commit "feat: add legacy grade calculator"

# ---------------------------------------------------------------- weighted
git checkout -q -b feature/weighted-average dev
python3 - <<'EOF'
p = "grade_calculator.py"
s = open(p).read()
s = s.replace('''    "Evan": [80, 79.8, 80, 80],
}
''', '''    "Evan": [80, 79.8, 80, 80],
}

# Registrar policy: the final exam counts the most.
WEIGHTS = {
    "homework": 0.20,
    "quiz": 0.20,
    "midterm": 0.25,
    "final": 0.35,
}
''')
s = s.replace('''def get_letter_grade''', '''def calculate_weighted_average(scores, weights):
    """Return the weighted average of scores using the category weights."""
    if len(scores) != len(weights):
        raise ValueError("expected one score per weighted category")
    if abs(sum(weights.values()) - 1.0) > 1e-9:
        raise ValueError("weights must sum to 1.0")
    return sum(score * weight for score, weight in zip(scores, weights.values()))


def get_letter_grade''')
open(p, "w").write(s)
EOF
commit "feat: add weighted average helper and category weights"
sed -i 's/        average = calculate_average(scores)/        average = calculate_weighted_average(scores, WEIGHTS)/' grade_calculator.py
commit "feat: use weighted average when computing final grades"

# ---------------------------------------------------------------- detailed output
git checkout -q -b feature/detailed-output dev
python3 - <<'EOF'
p = "grade_calculator.py"
s = open(p).read()
s = s.replace('''def format_report(name, average, grade):
    """Build a one-line report for a student."""
    return f"{name}: {average:.1f} ({grade})"
''', '''def format_report(name, scores, avg, grade):
    """Build a detailed table row: scores, low, high, average and grade."""
    scoreList = ", ".join('%g' % s for s in scores)
    return '%-8s %-22s %5g %5g %8.1f %6s' % (name, scoreList, min(scores), max(scores), avg, grade)
''')
s = s.replace('''    print("Grade Report")
    print("------------")
    for name, scores in STUDENTS.items():
        average = calculate_average(scores)
        grade = get_letter_grade(int(average))
        print(format_report(name, average, grade))
''', '''    header = '%-8s %-22s %5s %5s %8s %6s' % ('Name', 'Scores', 'Low', 'High', 'Average', 'Grade')
    print(header)
    print('-' * len(header))
    for name, scores in STUDENTS.items():
        avg = calculate_average(scores)
        grade = get_letter_grade(int(avg))
        print(format_report(name, scores, avg, grade))
''')
open(p, "w").write(s)
EOF
commit "feat: show detailed per-student table with low/high scores"
python3 - <<'EOF'
p = "grade_calculator.py"
s = open(p).read()
s = s.replace('''        print(format_report(name, scores, avg, grade))
''', '''        print(format_report(name, scores, avg, grade))
    print('-' * len(header))
    print('Students: %d' % len(STUDENTS))
''')
open(p, "w").write(s)
EOF
commit "feat: add footer with student count to detailed report"

# ---------------------------------------------------------------- strict grading
git checkout -q -b feature/strict-grading dev
python3 - <<'EOF'
p = "grade_calculator.py"
s = open(p).read()
s = s.replace('''def get_letter_grade(average):
    """Map a numeric average to a letter grade."""
    if average >= 90:
        return "A"
    elif average >= 80:
        return "B"
    elif average >= 70:
        return "C"
    elif average >= 60:
        return "D"
    else:
        return "F"
''', '''def validate_scores(scores):
    """Reject any score outside the valid percentage range."""
    for score in scores:
        if not 0 <= score < 100:
            raise ValueError(f"invalid score: {score}")


def get_letter_grade(average):
    """Map a numeric average to a letter grade (strict scale)."""
    if average >= 93:
        return "A"
    elif average >= 85:
        return "B"
    elif average >= 77:
        return "C"
    elif average >= 70:
        return "D"
    else:
        return "F"
''')
s = s.replace('''    for name, scores in STUDENTS.items():
        average = calculate_average(scores)
''', '''    for name, scores in STUDENTS.items():
        validate_scores(scores)
        average = calculate_average(scores)
''')
open(p, "w").write(s)
EOF
commit "feat: enforce strict grading scale and validate score input"

# ---------------------------------------------------------------- plus/minus
git checkout -q -b feature/plus-minus-grades dev
python3 - <<'EOF'
p = "grade_calculator.py"
s = open(p).read()
s = s.replace('''def get_letter_grade(average):
    """Map a numeric average to a letter grade."""
    if average >= 90:
        return "A"
    elif average >= 80:
        return "B"
    elif average >= 70:
        return "C"
    elif average >= 60:
        return "D"
    else:
        return "F"
''', '''def get_letter_grade(average):
    """Map a numeric average to a letter grade with +/- modifiers."""
    if average >= 90:
        letter = "A"
    elif average >= 80:
        letter = "B"
    elif average >= 70:
        letter = "C"
    elif average >= 60:
        letter = "D"
    else:
        return "F"
    return letter + get_modifier(average)


def get_modifier(average):
    """Return "+" for the top of a band, "-" for the bottom, else ""."""
    position = min(average, 99.99) % 10
    if position >= 7:
        return "+"
    if position < 3:
        return "-"
    return ""
''')
open(p, "w").write(s)
EOF
commit "feat: add plus/minus modifiers to letter grades"
python3 - <<'EOF'
p = "grade_calculator.py"
s = open(p).read()
s = s.replace('''    print("Grade Report")
    print("------------")
''', '''    print("Grade Report")
    print("Scale: A/B/C/D with +/- modifiers, F has no modifier")
    print("------------")
''')
open(p, "w").write(s)
EOF
commit "docs: print the plus/minus grading scale in the report header"

# ---------------------------------------------------------------- rounding fix
git checkout -q -b fix/rounding-bug dev
sed -i 's/        grade = get_letter_grade(int(average))/        grade = get_letter_grade(round(average, 1))/' grade_calculator.py
commit "fix: grade the rounded average instead of truncating it

int() truncated 89.975 to 89, so Diana was shown 90.0 but graded B.
Rounding to one decimal makes the grade match the displayed average."
python3 - <<'EOF'
p = "grade_calculator.py"
s = open(p).read()
s = s.replace('''        grade = get_letter_grade(round(average, 1))
''', '''        print("DEBUG raw average:", repr(average))
        grade = get_letter_grade(round(average, 1))
''')
open(p, "w").write(s)
EOF
commit "debug: print raw averages while chasing rounding issue"

git checkout -q dev
echo "Practice repo ready in $(pwd). Branches:"
git branch --list
