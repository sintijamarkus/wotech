/*
** my_printf.c
** A minimal printf reimplementation using only write(2) and stdarg.
** Handled conversions: %d, %i, %c, %s, %p and the literal %%.
** Any unknown conversion (e.g. "%z") is copied through verbatim.
*/

#include <stdarg.h>
#include <stddef.h>
#include "my_printf.h"

/* ap is passed by pointer: passing a va_list by value and then       */
/* continuing to use it in the caller is undefined per the C standard.*/
static int convert(char specifier, va_list *ap)
{
    switch (specifier) {
        case 'd':
        case 'i':
            return my_putnbr((long)va_arg(*ap, int));
        case 'c':
            return my_putchar((char)va_arg(*ap, int));
        case 's':
            return my_putstr(va_arg(*ap, char *));
        case 'p':
            return my_putptr(va_arg(*ap, void *));
        case '%':
            return my_putchar('%');
        default:
            /* Unknown specifier: print the '%' and the character. */
            return my_putchar('%') + my_putchar(specifier);
    }
}

int my_printf(char *restrict format, ...)
{
    va_list ap;
    int count = 0;
    int i = 0;

    if (format == NULL)
        return -1;
    va_start(ap, format);
    while (format[i] != '\0') {
        if (format[i] == '%' && format[i + 1] != '\0') {
            i++;
            count += convert(format[i], &ap);
        } else {
            count += my_putchar(format[i]);
        }
        i++;
    }
    va_end(ap);
    return count;
}
