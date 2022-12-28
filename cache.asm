%include "./io.mac"
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

load:
    push ebp
    mov ebp, esp
    pusha

    mov eax, [ebp + 8]  ; address of reg
    mov ebx, [ebp + 12] ; tags
    mov ecx, [ebp + 16] ; cache
    mov edx, [ebp + 20] ; address
    mov edi, [ebp + 24] ; to_replace (index of the cache line that needs to be replaced in case of a cache MISS)

    mov &to_replace, edi
    mov &tag_iterator, dword 0
    mov &index, dword 0
   
    ;; - First step: We calculate the tag
    mov ebp, dword edx
    shr ebp, 3
    mov &tag, ebp
    ;; - Calculate offset
    mov ebp, dword edx
    and ebp, 7
    mov &offset, ebp

    ;; - Iterate through tags and compare them to the tag we calculated. 
    ;; - If it is found on position "i", it is a "Cache HIT".
    ;; - We populate the register with the value cache[i][offset]
my_loop:
    ;; mutam in ebp tag-ul de la indexul tag_iterator si comparam cu tag-ul calculat
    ;; - Move to EBP the tag found at the index tag_iterator and compare it with the calculated tag
    ;; - If they are equal, we found the element searched in cahce, so it is the case "Cache HIT"
    mov ebp, &tag_iterator
    mov edi, &tag
    cmp [ebx + ebp], edi
    je cache_hit

    ;; Verify that the tag found at the searched index is empty.
    cmp [ebx + ebp], byte 0x00
    jne increment_29

    ;; If it is empty, we increment by 1 and move on.
    add &tag_iterator, dword 1
    jmp continue_loop

    ;; If it isn't, we increment by 29 (tag's length) and move on.
    increment_29:
    add &tag_iterator, dword TAG_BITS
    
    continue_loop:
    add &index, dword 1
    mov ebp, &index
    cmp ebp, dword CACHE_LINES
    jl my_loop

;;;;;;;;;;;;;;;;;;;;;; CACHE MISS ;;;;;;;;;;;;;;;;;;;;;;
    mov ebp, &tag
    shl ebp, 3
    mov &start_address, ebp

    ;; The goal is to multiply to_replace index by 8 to get to the to_replace line from cache.
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
    ;; Move in cache[multiplied_to_replace][index] the start address.
    mov ebp, &index
    add ebp, &multiplied_to_replace
    mov edi, &start_address
    mov edi, [edi]
    mov [ecx + ebp], edi
    ;; Increment start address by 1 bit at a time
    add &start_address, dword 1

    ;; Increment the index and repeat the process 8 times
    add &index, dword 1
    cmp &index, dword 8
    jl cache_miss
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;; Iterate through the tags until we reach to_replace
    mov edi, &to_replace
    mov &index, dword 0
    mov &tag_iterator, dword 0
    move_to_tags:
        mov ebp, &tag_iterator
        cmp [ebx + ebp], byte 0x00
        jne increment29

        add &tag_iterator, dword 1
        jmp re_loop

        increment29:
        add &tag_iterator, dword TAG_BITS

        re_loop:
        add &index, dword 1
        cmp &index, edi
        jl move_to_tags
    
    ;; Move in tags[to_replace] the tag
    mov edi, &tag_iterator
    mov ebp, &tag
    mov [ebx + edi], ebp

    ;; Make the current index take to_replace's value to move cache[i][offset] in the register
    mov edi, &to_replace
    mov &index, edi
;;;;;;;;;;;;;;;;;;;;;; CACHE HIT ;;;;;;;;;;;;;;;;;;;;;;
cache_hit:
    mov edi, &index
    
    ;; Multiply the index by 8 (because the cache has 8 bytes on each line)
    mov &index, dword 0
    mov ebp, 0
    multiply8:
        add ebp, edi
        add &index, dword 1
        cmp &index, dword 8
        jl multiply8
    mov &index, ebp
    
    ; Move cache[index][offset] in the register 
    mov ebp, &index
    add ebp, &offset
    mov ebp, [ecx + ebp]
    mov [eax], ebp

    popa
    leave
    ret



