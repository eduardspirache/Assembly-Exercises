%include "./io.mac"
;; defining constants, you can use these as immediate values in your code
CACHE_LINES  EQU 100
CACHE_LINE_SIZE EQU 8
OFFSET_BITS  EQU 3
TAG_BITS EQU 29 ; 32 - OFSSET_BITS

section .data
    tag_iterator dd 0
    index dd 0
    tag dd 0
    offset dd 0
    to_replace dd 0
    start_address dd 0
    multiplied_to_replace dd 0

section .text
    global load
    extern printf

;; void load(char* reg, char** tags, char cache[CACHE_LINES][CACHE_LINE_SIZE], char* address, int to_replace);
load:
    ;; DO NOT MODIFY
    push ebp
    mov ebp, esp
    pusha

    mov eax, [ebp + 8]  ; address of reg
    mov ebx, [ebp + 12] ; tags
    mov ecx, [ebp + 16] ; cache
    mov edx, [ebp + 20] ; address
    mov edi, [ebp + 24] ; to_replace (index of the cache line that needs to be replaced in case of a cache MISS)
    ;; DO NOT MODIFY
    ;; TODO: Implment load
    ;; FREESTYLE STARTS HERE
    mov &to_replace, edi
    mov &tag_iterator, dword 0
    mov &index, dword 0
   
    ;; Calculam tag-ul -> Pas1
    mov ebp, dword edx
    shr ebp, 3
    mov &tag, ebp
    ;; Calculam offset
    mov ebp, dword edx
    and ebp, 7
    mov &offset, ebp

    ;; Iteram prin taguri si comparam cu tag-ul nostru calculat. Daca il gasim pe pozitia i, avem Cache HIT =>
    ;; aducem din cache in registru valoarea cache[i][offset]
my_loop:
    ;; mutam in ebp tag-ul de la indexul tag_iterator si comparam cu tag-ul calculat
    ;; daca sunt egale, inseamna ca am gasit elementul cautat in cache, atunci suntem pe cazul Cache HIT

    mov ebp, &tag_iterator
    mov ebp, [ebx + ebp]
    cmp ebp, &tag
    je cache_hit

    ;; verificam daca tagul de la indexul nostru din tags este gol.
    cmp ebp, 0x00
    jne increment_29

    ;; daca este, incrementam cu 1 si continuam
    mov ebp, &tag_iterator
    add ebp, dword 1
    jmp continue_loop

    ;; daca nu este, incrementam cu 29 (lungimea tagului) si continuam
    increment_29:
    mov ebp, &tag_iterator
    add ebp, TAG_BITS
    
    continue_loop:
    mov &tag_iterator, ebp
    add &index, dword 1
    cmp ebp, CACHE_LINES
    jl my_loop

;;;;;;;;;;;;;;;;;;;;;; CACHE MISS ;;;;;;;;;;;;;;;;;;;;;;
    mov ebp, &tag
    shl ebp, 3
    mov &start_address, ebp ;; adresa de start este tagul cu 000 la final

    ;; vrem sa multiplicam indexul to_replace cu 8 pentru a ajunge la linia to_replace din cache
    mov &index, dword 0
    mov ebp, 0
    multiply_to_8:
        add ebp, &to_replace
        add &index, dword 1
        cmp &index, dword 8
        jl multiply_to_8
    mov &multiplied_to_replace, ebp

    mov &index, dword 0
cache_miss:
    ;; mut in cache[multiplied_to_replace][index] start address
    mov ebp, &index
    add ebp, &multiplied_to_replace
    mov edi, &start_address
    mov edi, [edi]
    mov [ecx + ebp], edi
    ;; incrementez start address cu cate 1 bit
    add &start_address, dword 1

    ;; incrementez indexul si repet de 8 ori
    add &index, dword 1
    cmp &index, dword 8
    jl cache_miss
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;; Iterez prin tag-uri pana ajung la to_replace
    mov edi, &to_replace
    mov &index, dword 0
    mov &tag_iterator, dword 0
    move_to_tags:
        mov ebp, ebx
        add ebp, &tag_iterator
        cmp ebp, 0x00
        jne increment29

        add &tag_iterator, dword 1

        increment29:
        add &tag_iterator, dword TAG_BITS

        add &index, dword 1
        cmp &index, edi
        jl move_to_tags
    
    ;; Mut in tags[to_replace] tag-ul
    mov edi, &tag_iterator
    mov ebp, &tag
    mov [ebx + edi], ebp
    
    ;; Facem indexul to_replace pentru a putea muta in registru cache[i][offset]
    mov edi, &to_replace
    mov &index, edi
;;;;;;;;;;;;;;;;;;;;;; CACHE HIT ;;;;;;;;;;;;;;;;;;;;;;
cache_hit:
    mov edi, &index

    ;; Inmultim indexul cu 8 (pentru ca cache-ul nostru are 8 bytes pe linie)
    mov &index, dword 0
    mov ebp, 0
    multiply8:
        add ebp, edi
        add &index, dword 1
        cmp &index, dword 8
        jl multiply8
    mov &index, ebp
    
    ; Mutam in registru cache[index][offset]
    mov ebp, &index
    add ebp, &offset
    mov ebp, [ecx + ebp]
    mov [eax], ebp

    ;; FREESTYLE ENDS HERE
    ;; DO NOT MODIFY
    popa
    leave
    ret
    ;; DO NOT MODIFY


