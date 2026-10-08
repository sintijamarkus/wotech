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
        average = calculate_weighted_average(scores, WEIGHTS)
        grade = get_letter_grade(int(average))
        print(format_report(name, average, grade))


if __name__ == "__main__":
    main()
