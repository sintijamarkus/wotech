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

# Registrar policy: the final exam counts the most.
WEIGHTS = {
    "homework": 0.20,
    "quiz": 0.20,
    "midterm": 0.25,
    "final": 0.35,
}


def calculate_average(scores):
    """Return the arithmetic mean of a list of scores."""
    return sum(scores) / len(scores)


def calculate_weighted_average(scores, weights):
    """Return the weighted average of scores using the category weights."""
    if len(scores) != len(weights):
        raise ValueError("expected one score per weighted category")
    if abs(sum(weights.values()) - 1.0) > 1e-9:
        raise ValueError("weights must sum to 1.0")
    return sum(score * weight for score, weight in zip(scores, weights.values()))


def get_letter_grade(average):
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


def format_report(name, scores, average, grade):
    """Build a detailed table row: scores, low, high, average and grade."""
    score_list = ", ".join(f"{score:g}" for score in scores)
    return (
        f"{name:<8} {score_list:<22} {min(scores):>5g} {max(scores):>5g} "
        f"{average:>8.1f} {grade:>6}"
    )


def main():
    print("Scale: A/B/C/D with +/- modifiers, F has no modifier")
    header = (
        f"{'Name':<8} {'Scores':<22} {'Low':>5} {'High':>5} "
        f"{'Average':>8} {'Grade':>6}"
    )
    print(header)
    print("-" * len(header))
    for name, scores in STUDENTS.items():
        average = calculate_weighted_average(scores, WEIGHTS)
        grade = get_letter_grade(round(average, 1))
        print(format_report(name, scores, average, grade))
    print("-" * len(header))
    print(f"Students: {len(STUDENTS)}")


if __name__ == "__main__":
    main()
