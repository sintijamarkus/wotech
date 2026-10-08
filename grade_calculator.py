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
