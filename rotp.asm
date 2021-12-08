section .text
    global rotp

;; void rotp(char *ciphertext, char *plaintext, char *key, int len);
rotp:
    ;; DO NOT MODIFY
    push    ebp
    mov     ebp, esp
    pusha

    mov     edx, [ebp + 8]  ; ciphertext
    mov     esi, [ebp + 12] ; plaintext
    mov     edi, [ebp + 16] ; key
    mov     ecx, [ebp + 20] ; len
    ;; DO NOT MODIFY

    ;; TODO: Implment rotp
    ;; FREESTYLE STARTS HERE

    xor ebx, ebx ;; Facem ebx = i = 0
modify_ciphertext:
    mov al, [esi + ebx]
    mov ebp, ecx
    sub ebp, ebx
    sub ebp, 1
    mov ah, [edi + ebp]
    xor al, ah
    
    mov [edx + ebx], al
    
    add ebx, 1
    cmp ebx, ecx
    jne modify_ciphertext

    ;; FREESTYLE ENDS HERE
    ;; DO NOT MODIFY
    popa
    leave
    ret
    ;; DO NOT MODIFY