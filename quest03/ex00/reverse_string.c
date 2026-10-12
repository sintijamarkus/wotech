#include <stdio.h>

char* reverse_string(char* str)
{
  int len = 0;
  while (str[len] != '\0') {
    len++;
  }

  int start = 0;
  int end = len - 1;

  while (start < end) {
    char temp = str[start];
    str[start] = str[end];
    str[end] = temp;
    start++;
    end--;
  }

  return str;
}
