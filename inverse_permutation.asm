global inverse_permutation

inverse_permutation:
        mov     rdx, rsi

        ; rdi: n
        ; rdx: *p

;
;  Check if 0 < n <= int_max + 1, return false if not.
;
check_n:
        ; test = ((n - 1) < int_max)
        lea     rcx, [rdi - 1]  ; rcx = n - 1 to use as a counter later
        cmp     rcx, 0x7fffffff  ; int_max

        ; if (!test) return false
        jbe     .skip_return_false
.return_false:
        xor     eax, eax
        ret
.skip_return_false:


;
;  Check if all numbers are between 0 and n - 1, return false if not.
;
;  It is important to do this 0 --> n.
;
check_range:
        ; for (i = 0; i < n; ++i)
        xor     eax, eax
.loop:
        mov     esi, dword [rdx + rax * 4]

        ; if (p[i] < 0) return false
        test    esi, esi
        js      check_n.return_false

        ; if (p[i] > n) return false
        cmp     rsi, rdi
        jnb     check_n.return_false

        ; continue
        inc     rax
        cmp     rdi, rax
        jne     .loop

;
;  Check if the input is a correct permutation.
;
;
;  To tag elements as 'visited', we convert x to -x - 1, which is equal to ~x.
;  Then, a value < 0 means an element has been visited, and ~x is the original
;  value.
;
;  We loop through i = 0, ...n, and tag each p[i]. If p[i] has already been
;  tagged, then the permutation is incorrect. In this case, we need to reverse
;  all the tagging we've done.
;
;  rdi: i -- the index of the current element
;  r8d: x -- p[i]
;  rcx: j -- the index of the current element in the rollback
;  r9: &p[x]
;
check_permutation:
        ; for (i = n; i-- > 0;)
        mov     rdi, rcx
.outer:
        ; x = p[i]
        mov     r8d, dword [rdx + rdi*4]

        ; if (x < 0) x = ~x
        mov     esi, r8d
        sar     esi, 31
        xor     esi, r8d

        ; &p[x]
        lea     r9, [rdx + rsi*4]

        ; if (p[x] < 0)
        mov     esi, dword [r9]
        test    esi, esi
        jns     .skip_rollback

        ; The permutation is incorrect. Undo the tagging and return.

        ; for (j = n; j-- > 0;)
.inner:
        ; if (p[j] < 0)
        mov     eax, dword [rdx + rcx*4]
        test    eax, eax
        jns     .skip_assignment
                ; p[j] = ~p[j]
                not     eax
                mov     dword [rdx + rcx*4], eax
        .skip_assignment:

        ; continue
        sub     rcx, 1
        jnb     .inner
        jmp     check_n.return_false
.skip_rollback:  ; The permutation is correct.
        ; p[x] = ~p[x]
        not     esi
        mov     dword [r9], esi

        ; continue
        sub     rdi, 1
        jnb     .outer


;
;  Untag all elements.
;
simple_untag:
        ; for(i = n; i-- > 0;)
.loop:
        not     dword [rdx + rcx*4]

        sub     rcx, 1
        jnb     .loop


;
;  Find inverse of the permutation.
;
;  We go from the end of the permutation; if an element was not visited, we
;  traverse the cycle created by connecting each x to p[x], and update the
;  array. Elements that have been set are tagged. At the end of each iteration,
;  one element is untagged (we know its tag won't be queried because all
;  elements in the cycle with this element have already been visited).
;
;  | eax | start   | the start of the cycle
;  | esi | current | current element of the cycle
;  | r8d | next    | next element of the cycle
;  | ecx | value   | what should be p[start] set to
;

find_inverse:
; for (start = n - 1; start-- > 0;)
        dec     eax
.loop:
        ; <condition>
        lea     ecx, [rax + 1]
        test    ecx, ecx
        jle     return_true

        ; current = p[start]
        mov     esi, dword [rdx + rax * 4]

        ; value = ~p[start]
        mov     ecx, esi
        not     ecx

        ; if (p[start] < 0) skip walk_cycle
        test    esi, esi
        js      .end_walk_cycle

        ; previous = start
        mov     ecx, eax

        ; while (current != start)
.walk_cycle:
        ; <condition>
        cmp     esi, eax
        je      .end_walk_cycle

        ; next = p[current]
        mov     edi, esi
        lea     rdi, [rdx + rdi*4]  ; rdi = &p[current]
        mov     r8d, dword [rdi]

        ; p[current] = ~previous; previous = nil
        not     ecx
        mov     dword [rdi], ecx

        ; previous = current
        mov     ecx, esi

        ; current = next
        mov     esi, r8d

        ; continue
        jmp     .walk_cycle
.end_walk_cycle:

        ; p[start] = value
        mov     dword [rdx + rax*4], ecx

        ; continue
        dec     eax
        jmp     .loop


return_true:
        mov     al, 1
        ret
