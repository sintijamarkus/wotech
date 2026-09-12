/*
** my_printf.h
** Public declarations for the my_printf project.
*/

#ifndef MY_PRINTF_H_
#define MY_PRINTF_H_

/* Main entry point: a small reimplementation of printf.        */
/* Supports the conversions: %d, %i, %c, %s, %p and %%.         */
/* Returns the number of characters written to stdout.          */
int my_printf(char *restrict format, ...);

/* --- Low level output helpers (write-based, no buffering) --- */

/* Writes a single character to stdout, returns 1. */
int my_putchar(char c);

/* Writes a NUL-terminated string, returns the number of        */
/* characters written. A NULL pointer prints "(null)".         */
int my_putstr(const char *str);

/* Writes a signed decimal number, returns the count written.   */
/* The argument is a long so that INT_MIN can be negated safely.*/
int my_putnbr(long nb);

/* Writes an unsigned number in lowercase hexadecimal.          */
int my_puthex(unsigned long nb);

/* Writes a pointer as printf's %p does ("0x..." or "(nil)").   */
int my_putptr(void *ptr);

#endif /* MY_PRINTF_H_ */
