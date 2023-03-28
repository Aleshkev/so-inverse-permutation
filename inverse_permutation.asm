global inverse_permutation

inverse_permutation:

;'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
;  Function input:
;  | rdx | *p
;  | rcx | n
;,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,


;'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
;  Check if 0 < n <= int_max + 1, return false if not.
;,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,

check_n:
        lea     rcx, [rdi - 1]
        mov     rdx, rsi
        xor     eax, eax
        cmp     rcx, 0x7fffffff  ; int_max

        ;
        jbe     .skip_return_false

        .return_false:
                xor     eax, eax
                ret
        .skip_return_false:


;'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
;  Check if all numbers are between 0 and n - 1, return false if not.
;,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,

check_range:

.loop:
        movsx   rsi, dword [rdx + rax * 4]
        test    esi, esi
        js      check_n.return_false
        cmp     rsi, rdi
        jnb     check_n.return_false
        inc     rax
        cmp     rdi, rax
        jne     .loop

        mov     rdi, rcx

;''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
;  Check if the input is a correct permutation.
;,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
;
;  To tag elements as 'visited', we convert x to -x - 1, which is equal to ~x.
;  Then, a value < 0 means an element has been visited, and ~x is the original
;  value.
;
;  We loop through i = 0, ...n, and tag each p[i]. If p[i] has already been
;  tagged, then the permutation is incorrect. In this case, we need to reverse
;  all the tagging we've done.
;
;,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
;
;  Variables
;  | rax | i     | the index of the current element
;  | r8d | x     | p[i]
;  | rcx | j     | the index of the current element in the rollback
;  | r9  | &p[x]
;

check_permutation:

; for (i = n; i-- > 0;)
.outer:
        ; x = p[i]
        mov     r8d, dword [rdx + rdi * 4]

        ; if (x < 0) x = ~x
        mov     esi, r8d
        sar     esi, 31
        xor     esi, r8d

        ; &p[x]
        movsx   rsi, esi
        lea     r9, [rdx + rsi * 4]

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
        .skip_rollback:

        ; p[x] = ~p[x]
        not     esi
        mov     dword [r9], esi

        ; continue
        sub     rdi, 1
        jnb     .outer


;'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
;  Untag all elements.
;,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
;
;  Variable:
;  | rcx | i | the counter
;,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,

simple_untag:

; for(i = n; i-- > 0;)
.loop:
        ; p[i] = ~p[i]
        not     dword [rdx + rcx * 4]

        ; continue
        sub     rcx, 1
        jnb     .loop


;'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
;  Find inverse of the permutation.
;,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
;
;  Variables:
;  | eax | start   | the start of the cycle
;  | esi | current | current element of the cycle
;  | r8d | next    | next element of the cycle
;  | ecx | value   | what should be p[start] set to
;,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,

find_inverse:

; for (start = n - 1; start-- > 0;)
        dec     eax
        ;   cdqe
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
                movsx   rdi, esi
                lea     rdi, [rdx+rdi*4]
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
