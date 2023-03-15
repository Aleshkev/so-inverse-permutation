//
//      bool inverse_permutation(size_t n, int *p)
//
// Argumentami funkcji są wskaźnik p na niepustą tablicę liczb całkowitych oraz
// rozmiar tej tablicy n. Jeśli tablica wskazywana przez p zawiera permutację
// liczb z przedziału od 0 do n-1, to funkcja odwraca tę permutację w miejscu,
// a wynikiem funkcji jest true. W przeciwnym przypadku wynikiem funkcji jest
// false, a zawartość tablicy wskazywanej przez p po zakończeniu wykonywania
// funkcji jest taka sama jak w momencie jej wywołania. Funkcja powinna wykrywać
// ewidentnie niepoprawne wartości n – patrz przykład użycia. Wolno natomiast
// założyć, że wskaźnik p jest poprawny.

#include <limits.h>
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>

#define lsb ((uint32_t)1 << 31)

#define is_tagged(x) ((x)&lsb)
#define tagged(x) ((x) | lsb)
#define untagged(x) ((x) & (lsb - 1))

bool inverse_permutation(size_t n, int *p) {
  //   printf("using C version\n");

  if (n == 0 || n > INT_MAX) {
    return false;
  }

  // We will store an additional bit of information in the most significant bit.
  uint32_t *v = (void *)p;

  // If a number in the input is negative, this bit will be set. So we do a
  // quick check if this is the case (the permutation is then incorrect).
  for (size_t i = 0; i < n; ++i) {
    if (is_tagged(v[i])) {
      return false;
    }
  }

  bool ans = true;

  // Detect duplicates, ensure numbers are smaller than n.
  // If v[i] = x, we tag v[x] to remember that x occurred.
  for (size_t i = 0; i < n; ++i) {
    uint32_t x = untagged(v[i]);
    if (x >= n || is_tagged(v[x])) {
      ans = false;
      goto undo_and_return;
    }

    v[x] = tagged(v[x]);
  }

  // Undo the tagging.
  for (size_t i = 0; i < n; ++i) {
    v[i] = untagged(v[i]);
  }

  // The permutation is correct from now on.

  for (size_t i = 0; i < n; ++i) {
    if (is_tagged(v[i])) {
      continue;
    }

    // Reverse one cycle.
    size_t prev = i;
    for (size_t j = v[i]; j != i;) {
      size_t next = v[j];
      v[j] = tagged(prev);
      prev = j;
      j = next;
    }
    v[i] = tagged(prev);
  }

undo_and_return:

  // Undo the tagging.
  for (size_t i = 0; i < n; ++i) {
    v[i] = untagged(v[i]);
  }

  return ans;
}