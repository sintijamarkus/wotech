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


def format_report(name, scores, avg, grade):
    """Build a detailed table row: scores, low, high, average and grade."""
    scoreList = ", ".join('%g' % s for s in scores)
    return '%-8s %-22s %5g %5g %8.1f %6s' % (name, scoreList, min(scores), max(scores), avg, grade)


def main():
    header = '%-8s %-22s %5s %5s %8s %6s' % ('Name', 'Scores', 'Low', 'High', 'Average', 'Grade')
    print(header)
    print('-' * len(header))
    for name, scores in STUDENTS.items():
        avg = calculate_average(scores)
        grade = get_letter_grade(int(avg))
        print(format_report(name, scores, avg, grade))
    print('-' * len(header))
    print('Students: %d' % len(STUDENTS))


if __name__ == "__main__":
    main()
