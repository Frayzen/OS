#include "paging/page.h"

#define BEGIN_TEXT ((char *)0xb8000)
void print(char *c) {
  static int cursor = 0;
  while (*c)
    BEGIN_TEXT[2 * cursor++] = *(c++);
}

extern void kernel_start() {
  setupPaging();
  char *b = BEGIN_TEXT;
  for (int i = 0; i < 80 * 25; ++i) {
    b[2 * i] = ' ';
    b[2 * i + 1] = 0x0F;
  }
  print("Hello");
  print("World");
  while (1)
    ;
}
