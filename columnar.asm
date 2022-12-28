%include "./io.mac"
section .data
    extern len_cheie, len_haystack
    key_iterator dd 0
    hay_iterator dd 0
    cipher_iterator dd 0

section .text
    global columnar_transposition
    extern printf

columnar_transposition:
    push    ebp
    mov     ebp, esp
    pusha 

    mov edi, [ebp + 8]   ;key
    mov esi, [ebp + 12]  ;haystack
    mov ebx, [ebp + 16]  ;ciphertext

    mov &key_iterator, dword 0
    mov &hay_iterator, dword 0
    mov &cipher_iterator, dword 0

iterate_key:
    mov ecx, &key_iterator
    mov eax, [edi + 4 * ecx] ;; = key[key_iterator]
    mov &hay_iterator, eax ;; hay_iterator = key[key_iterator]
    iterate_haystack:
        mov eax, &cipher_iterator
        mov ecx, &hay_iterator
        
        mov dl, [esi + ecx] ;; ebp = haystack[hay_iterator]
        mov [ebx + eax], dl ;; cipher[chiper_iterator] = haystack[hay_iterator]

        add &cipher_iterator, dword 1 ;; cipher_iterator++
        
        ;; Halt conditions for iterate_haystack ;;
        mov ebp, &hay_iterator ;; ebp = hay_iterator
        add ebp, &len_cheie ;; ebp = hay_iterator + len_cheie
        mov &hay_iterator, ebp ;; hay_iterator = hay_iterator + len_cheie

        mov eax, &len_haystack ;; eax = len_haystack
        cmp &hay_iterator, eax ;; hay_iterator < len_haystack
        jl iterate_haystack
    
    ;; Halt conditions for iterate_key ;;
    add &key_iterator, dword 1 ;; key_iterator ++ (int)
    
    mov eax, &len_cheie ;; eax = len_cheie
    cmp &key_iterator, eax ;; key_iterator < len_cheie
    jl iterate_key

    popa
    leave
    ret