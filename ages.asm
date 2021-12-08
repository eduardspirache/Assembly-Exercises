; This is your structure
struc  my_date
    .day: resw 1
    .month: resw 1
    .year: resd 1
endstruc

section .text
    global ages

section .data
    minus dd 1

; void ages(int len, struct my_date* present, struct my_date* dates, int* all_ages);
ages:
    ;; DO NOT MODIFY
    push    ebp
    mov     ebp, esp
    pusha

    mov     edx, [ebp + 8]  ; len
    mov     esi, [ebp + 12] ; present
    mov     edi, [ebp + 16] ; dates
    mov     ecx, [ebp + 20] ; all_ages
    ;; DO NOT MODIFY

    ;; TODO: Implement ages
    ;; FREESTYLE STARTS HERE
    xor ebx, ebx
my_loop:
    ;copiem in eax anul curent si scadem anul nasterii jucatorului
    ;mutam varsta in vector, la indicele curent
    ;daca anul nasterii este mai mare decat anul datii curente, sarim peste
    mov eax, [esi + my_date.year]
    sub eax, [edi + ebx * my_date_size + my_date.year]

    cmp eax, 0
    jl finish

    mov [ecx + ebx * 4], eax
    ;comparam luna curenta cu luna nasterii
    ;daca este mai mica, inseamna ca nu a implinit varsta, asa ca scadem 1
    xor eax, eax
    mov al, [esi + my_date.month]
    sub al, [edi + ebx * my_date_size + my_date.month]
    cmp al, 0
    jg positive
negative:
    sub [ecx + ebx * 4], dword 1
positive:
    ;daca este mai mai mare sau egala, verificam daca este egala
    cmp al, 0
    jg finish
    ;daca luna curenta curenta este egala verificam ziua nasterii
    ;daca data este mai mare sau egala, lasam numarul de ani asa cum este
    xor eax, eax
    mov al, [esi + my_date.day]
    sub al, [edi + ebx * my_date_size + my_date.day]
    cmp al, 0
    jg finish
    sub [ecx + ebx * 4], dword 1
finish:
    add ebx, 1
    cmp ebx, edx
    jnz my_loop


    ;; FREESTYLE ENDS HERE
    ;; DO NOT MODIFY
    popa
    leave
    ret
    ;; DO NOT MODIFY
