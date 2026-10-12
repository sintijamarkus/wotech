/*
**
** QWASAR.IO -- my_strcmp
**
** @param {char*} param_1
** @param {char*} param_2
**
** @return {int}
**
*/

int my_strcmp(char* param_1, char* param_2)
{
  int i = 0;

  while (param_1[i] != '\0' && param_1[i] == param_2[i]) {
    i++;
  }

  return (unsigned char)param_1[i] - (unsigned char)param_2[i];
}
