;
;      bool inverse_permutation(size_t n, int *p);
;
; Argumentami funkcji są wskaźnik p na niepustą tablicę liczb całkowitych oraz
; rozmiar tej tablicy n. Jeśli tablica wskazywana przez p zawiera permutację
; liczb z przedziału od 0 do n-1, to funkcja odwraca tę permutację w miejscu,
; a wynikiem funkcji jest true. W przeciwnym przypadku wynikiem funkcji jest
; false, a zawartość tablicy wskazywanej przez p po zakończeniu wykonywania
; funkcji jest taka sama jak w momencie jej wywołania. Funkcja powinna wykrywać
; ewidentnie niepoprawne wartości n – patrz przykład użycia. Wolno natomiast
; założyć, że wskaźnik p jest poprawny.

global inverse_permutation

inverse_permutation:

        ; rdi: u64 n
        ; if n == 0 or n > INT_MAX then return
        lea     rax, [rdi - 2147483648]
        cmp     rax, -2147483647
        jae     .skip_return

.LBB0_1:
        xor     eax, eax
.return:
        ret

.skip_return:

        ; We check for numbers in the array outside the range of [0, n].
        ; If there are any, the input is incorrect. We check for this case here
        ; to make sure we don't access anything outside the array later.

        xor     eax, eax                  ; r: u64 = 0  @eax
        xor     ecx, ecx                  ; i: u64 = 0  @rcx
.check_bounds_loop:                       ; for
        mov     edx, dword [rsi + 4*rcx]  ;   x: i32 = p[i]  @edx
        test    edx, edx                  ;   if x < 0 then
        js      .return                   ;     return r
        cmp     rdx, rdi                  ;   if x >= n then
        jae     .return                   ;     return r
        inc     rcx                       ;   i = i + 1
        cmp     rdi, rcx                  ;   if i != n then
        jne     .check_bounds_loop        ;     continue
                                          ;   break

.check_duplicates_loop:
        mov     ecx, dword [rsi + 4*rax]
        and     ecx, 2147483647
        mov     edx, dword [rsi + 4*rcx]
        test    edx, edx
        js      .LBB0_21
        or      edx, -2147483648
        mov     dword [rsi + 4*rcx], edx
        inc     rax
        cmp     rdi, rax
        jne     .check_duplicates_loop
        xor     eax, eax
.LBB0_10:                               ; =>This Inner Loop Header: Depth=1
        mov     ecx, dword [rsi + 4*rax]
        and     ecx, 2147483647
        mov     dword [rsi + 4*rax], ecx
        and     byte [rsi + 4*rcx + 3], 127
        inc     rax
        cmp     rdi, rax
        jne     .LBB0_10
        xor     eax, eax
.LBB0_12:                               ; =>This Loop Header: Depth=1
        mov     ecx, dword [rsi + 4*rax]
        test    ecx, ecx
        js      .LBB0_16
        mov     rdx, rax
        cmp     rax, rcx
        je      .LBB0_15
.LBB0_14:                               ;   Parent Loop BB0_12 Depth=1
        mov     r8d, dword [rsi + 4*rcx]
        or      edx, -2147483648
        mov     dword [rsi + 4*rcx], edx
        mov     rdx, rcx
        mov     rcx, r8
        cmp     rax, r8
        jne     .LBB0_14
.LBB0_15:                               ;   in Loop: Header=BB0_12 Depth=1
        or      edx, -2147483648
        mov     dword [rsi + 4*rax], edx
.LBB0_16:                               ;   in Loop: Header=BB0_12 Depth=1
        inc     rax
        cmp     rax, rdi
        jne     .LBB0_12
        xor     eax, eax
.LBB0_18:                               ; =>This Inner Loop Header: Depth=1
        and     byte [rsi + 4*rax + 3], 127
        inc     rax
        cmp     rdi, rax
        jne     .LBB0_18
        mov     al, 1
        ret
.LBB0_21:
        test    rax, rax
        je      .LBB0_1
        xor     ecx, ecx
.LBB0_23:                               ; =>This Inner Loop Header: Depth=1
        mov     edx, dword [rsi + 4*rcx]
        and     edx, 2147483647
        mov     dword [rsi + 4*rcx], edx
        and     byte [rsi + 4*rdx + 3], 127
        inc     rcx
        cmp     rax, rcx
        jne     .LBB0_23
        jmp     .LBB0_1