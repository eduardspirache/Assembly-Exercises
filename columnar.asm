%include "./io.mac"
section .data
    extern len_cheie, len_haystack
    key_iterator dd 0
    hay_iterator dd 0
    cipher_iterator dd 0
    i dd 0

section .text
    global columnar_transposition
    extern printf

;; void columnar_transposition(int key[], char *haystack, char *ciphertext);
columnar_transposition:
    ;; DO NOT MODIFY
    push    ebp
    mov     ebp, esp
    pusha 

    mov edi, [ebp + 8]   ;key
    mov esi, [ebp + 12]  ;haystack
    mov ebx, [ebp + 16]  ;ciphertext
    ;; DO NOT MODIFY

    ;; TODO: Implment columnar_transposition
    ;; FREESTYLE STARTS HERE

    ;l_key -> lungime cheie si nr coloane
    ;l_plain->lungime plaintext si ceil(l_plain/l_key) + 1 nr linii
    ;pe prima linie -> key
    ;pe linia 1+ -> plaintext pana se termina
    ;printam coloanele fara prima linie in ordinea din key[]

iterate_key:
    mov ecx, &key_iterator
    mov eax, [edi + ecx] 
    mov &hay_iterator, eax

    iterate_haystack:
        mov eax, &cipher_iterator
        mov ecx, &hay_iterator

        mov ebp, [esi + ecx] ;; ebp = haystack[hay_iterator]

        mov [ebx + eax], ebp ;; cipher[chiper_iterator] = haystack[hay_iterator]
        add &cipher_iterator, dword 1 ;; cipher_iterator++

        ;; Conditii oprire iterate_haystack ;;

        mov ebp, &hay_iterator ;; ebp = hay_iterator
        add ebp, &len_cheie ;; ebp = hay_iterator + len_cheie
        mov &hay_iterator, ebp ;; hay_iterator = hay_iterator + len_cheie

        mov eax, &len_haystack ;; eax = len_haystack
        cmp &hay_iterator, eax ;; hay_iterator < len_haystack
        jl iterate_haystack
    
    ;; Conditii oprire iterate_key ;;
    add &key_iterator, dword 4 ;; key_iterator ++ (int)
    add &i, dword 1 ;; i = ++
    
    mov eax, &len_cheie ;; eax = len_cheie
    cmp &i, eax ;; key_iterator < len_cheie
    jl iterate_key

    ;; FREESTYLE ENDS HERE
    ;; DO NOT MODIFY
    popa
    leave
    ret
    ;; DO NOT MODIFY