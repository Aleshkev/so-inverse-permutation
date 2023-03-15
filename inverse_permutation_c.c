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
#include <stdint-gcc.h>
#include <stdio.h>

#define lsb ((uint32_t)1 << 31)

#define is_tagged(x) ((x) & lsb)
#define tagged(x) ((x) | lsb)
#define untagged(x) ((x) << 1 >> 1)

//#define tag(X) ((X) |= lsb)
//#define untagged(X) (((X) << 1) >> 1)
//#define untag(X) ((X) <<= 1, (X) >>= 1)
//#define tagged(X) ((X) << 1 >> 1)

#define swap(A, B) { A ^= B; B ^= A; A ^= B; }

bool inverse_permutation(size_t n, int *p) {
  if (n == 0 || n > INT_MAX) {
    return false;
  }

  // A permutation has integers in range [0, n - 1]
  for (size_t i = 0; i < n; ++i) {
    if (p[i] < 0 || p[i] >= n) {
      return false;
    }
  }



  // We will store an additional bit of information in the most significant bit.
  // This is not a sign bit, so to be less confusing let's just cast this to
  // unsigned.
  uint32_t *v = (void *)p;

  // Check if no numbers appear more than once.
  // If v[i] = x, we tag v[x] to remember that x occurred.
  for (size_t i = 0; i < n; ++i) {
    uint32_t x = untagged(v[i]);
    if (is_tagged(v[x])) {

      // Undo the changes
      for (size_t j = 0; j < i; ++j) {
        v[j] = untagged(v[j]);
        v[v[j]] = untagged(v[v[j]]);
      }

      return false;
    }

    v[x] = tagged(v[x]);
  }

  for (size_t i = 0; i < n; ++i) {
    v[i] = untagged(v[i]);
    v[v[i]] = untagged(v[v[i]]);
  }

  // Now we have a correct permutation.

  for (size_t i = 0; i < n; ++i) {
    if (is_tagged(v[i])) {
      continue;
    }

    // Now we reverse one cycle.

    size_t prev = i;
    for (size_t j = v[i]; j != i; ) {
      size_t next = v[j];
      v[j] = tagged(prev);
      prev = j;
      j = next;
    }
    v[i] = tagged(prev);
  }

  for(size_t i = 0; i < n; ++i) {
    v[i] = untagged(v[i]);
  }

  return true;
}