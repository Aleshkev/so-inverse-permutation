
global inverse_permutation

inverse_permutation:
        lea     rcx, [rdi-1]
        mov     rdx, rsi
        xor     eax, eax
        cmp     rcx, 2147483647
        jbe     .L2
.L4:
        xor     eax, eax
        jmp     .L1
.L2:
        movsx   rsi, DWORD  [rdx+rax*4]
        test    esi, esi
        js      .L4
        cmp     rsi, rdi
        jnb     .L4
        inc     rax
        cmp     rdi, rax
        jne     .L2
        mov     rdi, rcx
.L8:
        mov     r8d, DWORD  [rdx+rdi*4]
        mov     esi, r8d
        sar     esi, 31
        xor     esi, r8d
        movsx   rsi, esi
        lea     r8, [rdx+rsi*4]
        mov     esi, DWORD  [r8]
        test    esi, esi
        jns     .L5
.L7:
        mov     eax, DWORD  [rdx+rcx*4]
        test    eax, eax
        jns     .L6
        not     eax
        mov     DWORD  [rdx+rcx*4], eax
.L6:
        sub     rcx, 1
        jnb     .L7
        jmp     .L4
.L5:
        not     esi
        mov     DWORD  [r8], esi
        sub     rdi, 1
        jnb     .L8
.L9:
        not     DWORD  [rdx+rcx*4]
        sub     rcx, 1
        jnb     .L9
        dec     eax
        cdqe
.L10:
        lea     ecx, [rax+1]
        test    ecx, ecx
        jle     .L23
        mov     esi, DWORD  [rdx+rax*4]
        mov     ecx, esi
        not     ecx
        test    esi, esi
        js      .L13
        mov     ecx, eax
.L12:
        cmp     esi, eax
        je      .L13
        movsx   rdi, esi
        not     ecx
        lea     rdi, [rdx+rdi*4]
        mov     r8d, DWORD  [rdi]
        mov     DWORD  [rdi], ecx
        mov     ecx, esi
        mov     esi, r8d
        jmp     .L12
.L13:
        mov     DWORD  [rdx+rax*4], ecx
        dec     rax
        jmp     .L10
.L23:
        mov     al, 1
.L1:
        ret