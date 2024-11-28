section .data
    menu db "Calculadora Básica", 10, "1. Suma", 10, "2. Resta", 10, "3. Multiplicación", 10, "4. División", 10, "Elige una opción (1-4): ", 0
    op1_msg db "Ingresa el primer número: ", 0
    op2_msg db "Ingresa el segundo número: ", 0
    result_msg db "El resultado es: ", 0
    error_msg db "Opción inválida o error en la operación.", 10, 0
    newline db 10, 0

section .bss
    op1 resd 1
    op2 resd 1
    result resd 1
    buffer resb 10  ; Buffer para leer la entrada del usuario

section .text
    global _start

_start:
    ; Mostrar el menú
    mov eax, 4           ; sys_write
    mov ebx, 1           ; file descriptor (stdout)
    mov ecx, menu        ; dirección del mensaje
    mov edx, 65          ; longitud del mensaje
    int 0x80

    ; Leer opción del usuario
    call read_int
    mov ebx, eax         ; Guardar opción en ebx

    ; Solicitar primer número
    mov eax, 4
    mov ebx, 1
    mov ecx, op1_msg
    mov edx, 27
    int 0x80
    call read_int
    mov [op1], eax       ; Guardar primer número

    ; Solicitar segundo número
    mov eax, 4
    mov ebx, 1
    mov ecx, op2_msg
    mov edx, 27
    int 0x80
    call read_int
    mov [op2], eax       ; Guardar segundo número

    ; Realizar la operación seleccionada
    mov eax, [op1]
    mov ecx, [op2]
    cmp ebx, 1           ; Opción 1: Suma
    je add_op
    cmp ebx, 2           ; Opción 2: Resta
    je sub_op
    cmp ebx, 3           ; Opción 3: Multiplicación
    je mul_op
    cmp ebx, 4           ; Opción 4: División
    je div_op

    ; Opción inválida
    mov eax, 4
    mov ebx, 1
    mov ecx, error_msg
    mov edx, 38
    int 0x80
    jmp exit

add_op:
    add eax, ecx
    jmp print_result

sub_op:
    sub eax, ecx
    jmp print_result

mul_op:
    imul ecx
    jmp print_result

div_op:
    xor edx, edx         ; Limpiar edx para la división
    cmp ecx, 0           ; Verificar división por 0
    je error
    idiv ecx
    jmp print_result

error:
    mov eax, 4
    mov ebx, 1
    mov ecx, error_msg
    mov edx, 38
    int 0x80
    jmp exit

print_result:
    mov [result], eax
    mov eax, 4
    mov ebx, 1
    mov ecx, result_msg
    mov edx, 20
    int 0x80

    ; Imprimir el resultado
    mov eax, [result]
    call print_int

    ; Nueva línea
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80
    jmp exit

exit:
    mov eax, 1           ; sys_exit
    xor ebx, ebx         ; estado de salida
    int 0x80

; Rutinas auxiliares
read_int:
    ; Leer un número desde stdin
    mov eax, 3           ; sys_read
    mov ebx, 0           ; file descriptor (stdin)
    mov ecx, buffer      ; buffer para entrada
    mov edx, 10          ; tamaño máximo
    int 0x80
    ; Convertir ASCII a entero
    xor eax, eax
    xor esi, esi         ; índice para recorrer buffer
parse_digit:
    movzx edx, byte [buffer + esi]
    cmp dl, 10           ; Verificar fin de entrada
    je parse_done
    sub edx, '0'
    imul eax, eax, 10
    add eax, edx
    inc esi
    jmp parse_digit
parse_done:
    ret

print_int:
    ; Convertir entero a ASCII
    mov esi, 10
    xor ecx, ecx
    mov edi, buffer      ; Usar el buffer como temporal
convert_loop:
    xor edx, edx
    div esi
    add dl, '0'
    mov [edi + ecx], dl
    inc ecx
    test eax, eax
    jnz convert_loop

    ; Imprimir caracteres
    dec ecx
print_loop:
    mov al, [edi + ecx]
    mov [buffer], al
    mov eax, 4
    mov ebx, 1
    mov ecx, buffer
    mov edx, 1
    int 0x80
    loop print_loop
    ret
