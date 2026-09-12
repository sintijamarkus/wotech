/*
** main.c
** Manual test driver comparing my_printf against the real printf.
** printf is used ONLY here (in the test harness), never inside the
** my_printf implementation itself.
*/

#include <limits.h>
#include <stdio.h>
#include "my_printf.h"

int main(void)
{
    int r1;
    int r2;

    printf("== strings and chars ==\n");
    my_printf("Hello %s !\n", "World");
    my_printf("char: [%c]\n", 'A');
    my_printf("null string: [%s]\n", (char *)0);

    printf("== integers ==\n");
    my_printf("zero=%d one=%d neg=%d\n", 0, 1, -42);
    my_printf("INT_MAX=%d INT_MIN=%d\n", INT_MAX, INT_MIN);

    printf("== pointers ==\n");
    my_printf("stack ptr = %p\n", (void *)&r1);
    my_printf("null  ptr = %p\n", (void *)0);

    printf("== literal percent and unknown ==\n");
    my_printf("100%% done, unknown=%z\n");

    printf("== return value check ==\n");
    r1 = my_printf("abc");
    my_printf("\n");
    r2 = printf("abc");
    printf("\n");
    printf("my_printf returned %d, printf returned %d -> %s\n",
        r1, r2, (r1 == r2) ? "OK" : "MISMATCH");

    return 0;
}
