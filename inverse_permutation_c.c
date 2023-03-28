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

bool inverse_permutation(size_t n, int p[]) {
  if (n == 0 || n > (size_t)INT_MAX + 1) {
    return false;
  }

  for (size_t i = 0; i < n; ++i) {
    if (p[i] < 0 || (size_t)p[i] >= n)
      return false;
  }

  for (size_t i = n; i-- > 0;) {
    int x = p[i];
    if (x < 0)
      x = ~x;
    if (p[x] < 0) {
      for (size_t j = n; j-- > 0;) {
        if (p[j] < 0)
          p[j] = ~p[j];
      }
      return false;
    }
    p[x] = ~p[x];
  }
  for (size_t i = n; i-- > 0;) {
    p[i] = ~p[i];
  }

  for (int32_t start = (int32_t)n; start-- > 0;) {
    if (p[start] < 0) {
      p[start] = ~p[start];
      continue;
    }

    // < 0 --> było ustawione

    int previous = start;   // > 0
    int current = p[start]; // > 0
                            //    printf("%i ", start);
    while (current != start) {
      //      printf("%i ", current);
      int next = p[current];
      p[current] = ~previous;
      previous = current;
      current = next;
    }
    p[start] = previous;
    //    printf("%i \n", start);
  }

  return true;
}