struc  my_date
    .day: resw 1
    .month: resw 1
    .year: resd 1
endstruc

section .text
    global ages

section .data
    minus dd 1

ages:
    push    ebp
    mov     ebp, esp
    pusha

    mov     edx, [ebp + 8]  ; len
    mov     esi, [ebp + 12] ; present
    mov     edi, [ebp + 16] ; dates
    mov     ecx, [ebp + 20] ; all_ages
    xor ebx, ebx
my_loop:
    ; - Copy in EAX register the current year and decrease the player's birth year.
    ; - Move the age in the vector, at the current index
    ; - If the birth year is greater than current date, move on
    mov eax, [esi + my_date.year]
    sub eax, [edi + ebx * my_date_size + my_date.year]

    ; - If the current year is lower than birth year, make the vector's element 0 and jump to finish
    ; - Else continue the verification
    cmp eax, 0
    jg continue
    mov [ecx + ebx * 4], dword 0
    jmp finish
    
continue:
    mov [ecx + ebx * 4], eax
    ; - Compare current month with the birth month
    ; - If it is lower, it means that the birthday is yet to come, so decrease age by 1
    xor eax, eax
    mov al, [esi + my_date.month]
    sub al, [edi + ebx * my_date_size + my_date.month]
    cmp al, 0
    jge equal
negative:
    sub [ecx + ebx * 4], dword 1
    jmp finish
equal:
    ; - Check if it's greater or equal
    cmp al, 0
    jg finish
    ; - If the current month is equal to the birth month, verify birth day
    ; - If the current month is greater than the birth month, we don't modify
    xor eax, eax
    mov al, [esi + my_date.day]
    sub al, [edi + ebx * my_date_size + my_date.day]
    cmp al, 0
    jge finish
    sub [ecx + ebx * 4], dword 1
finish:
    add ebx, 1
    cmp ebx, edx
    jnz my_loop

    popa
    leave
    ret

