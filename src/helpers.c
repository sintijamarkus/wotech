/*
** helpers.c
** write(2)-based output primitives used by my_printf.
** No dynamic memory is allocated, so there is nothing to leak.
*/

#include <unistd.h>
#include <stddef.h>
#include "my_printf.h"

int my_putchar(char c)
{
    write(1, &c, 1);
    return 1;
}

int my_putstr(const char *str)
{
    int count = 0;

    if (str == NULL)
        str = "(null)";
    while (*str != '\0') {
        count += my_putchar(*str);
        str++;
    }
    return count;
}

int my_putnbr(long nb)
{
    int count = 0;

    if (nb < 0) {
        count += my_putchar('-');
        nb = -nb;
    }
    if (nb >= 10)
        count += my_putnbr(nb / 10);
    count += my_putchar((char)('0' + (nb % 10)));
    return count;
}

int my_puthex(unsigned long nb)
{
    const char *digits = "0123456789abcdef";
    int count = 0;

    if (nb >= 16)
        count += my_puthex(nb / 16);
    count += my_putchar(digits[nb % 16]);
    return count;
}

int my_putptr(void *ptr)
{
    int count = 0;

    if (ptr == NULL)
        return my_putstr("(nil)");
    count += my_putstr("0x");
    count += my_puthex((unsigned long)ptr);
    return count;
}
