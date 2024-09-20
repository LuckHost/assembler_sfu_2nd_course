format ELF executable 3  ; Указываем формат ELF (исполняемый файл Linux)

segment readable writeable
    prompt_x db 'Enter value for X: ', 0
    prompt_y db 'Enter value for Y: ', 0

    prompt_eq1 db 'Equation 1: X^3 - 2X^2*Y + 1', 0
    prompt_eq2 db 'Equation 2: -3X + Y^2 + 1', 0
    prompt_eq3 db 'Equation 3: -(X/Y + 1)/Y^2', 0
    prompt_eq4 db 'Equation 4: 1 + X^2 / 3Y', 0
    prompt_eq5 db 'Equation 5: Y - X/3 + 1', 0

    prompt_eq db 'Select equation (1-5): ', 0

    result_msg db 'Result Z: ', 0

    newline db 10, 0
    minus db '-', 0
    number_buf rb 12  ; Буфер для ввода числа
    div_ten dd 10
    div_three dd 3

segment readable writeable
    x dd 0
    y dd 0
    z dd 0
    equation dd 0

segment executable
    entry start

start:
    ; Ввод X
    mov eax, 4            ; sys_write
    mov ebx, 1            ; stdout
    mov ecx, prompt_x     ; строка для X
    mov edx, 17           ; длина строки
    int 0x80              ; системный вызов

    call input_number
    mov [x], eax          ; сохраняем X

    ; Ввод Y
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt_y
    mov edx, 17
    int 0x80

    call input_number
    mov [y], eax          ; сохраняем Y

    mov eax, 4
    mov ebx, 1
    mov ecx, prompt_eq1
    mov edx, 28
    int 0x80

    call print_newline

    mov eax, 4
    mov ebx, 1
    mov ecx, prompt_eq2
    mov edx, 25
    int 0x80

    call print_newline

    mov eax, 4
    mov ebx, 1
    mov ecx, prompt_eq3
    mov edx, 26
    int 0x80

    call print_newline

    mov eax, 4
    mov ebx, 1
    mov ecx, prompt_eq4
    mov edx, 24
    int 0x80

    call print_newline

    mov eax, 4
    mov ebx, 1
    mov ecx, prompt_eq5
    mov edx, 23
    int 0x80

    call print_newline

    ; Выбор уравнения
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt_eq
    mov edx, 24
    int 0x80

    call input_number
    mov [equation], eax  ; сохраняем выбранное уравнение

    ; Вычисление по выбранному уравнению
    mov eax, [equation]
    cmp eax, 1
    je eq1
    cmp eax, 2
    je eq2
    cmp eax, 3
    je eq3
    cmp eax, 4
    je eq4
    cmp eax, 5
    je eq5
    jmp exit

eq1:
    ; Z = X^3 - 2X^2*Y + 1
    mov eax, [x]
    imul eax, eax        ; X^2
    mov ebx, eax         ; сохраняем X^2 в ebx
    imul eax, [x]        ; X^3
    mov edx, ebx         ; X^2
    imul edx, [y]        ; X^2 * Y
    imul edx, 2          ; 2X^2 * Y
    sub eax, edx         ; X^3 - 2X^2 * Y
    add eax, 1           ; X^3 - 2X^2 * Y + 1
    jmp print_result

eq2:
    ; Z = -3X + Y^2 + 1
    mov eax, [x]
    imul eax, -3          ; -3X
    mov ebx, [y]
    imul ebx, ebx         ; Y^2
    add eax, ebx          ; -3X + Y^2
    add eax, 1            ; -3X + Y^2 + 1
    jmp print_result

eq3:
    ; Z = -(X/Y + 1)/Y^2
    mov eax, [x]
    cdq
    idiv dword [y]        ; X / Y
    add eax, 1            ; X / Y + 1
    neg eax               ; -(X/Y + 1)
    mov ebx, [y]
    imul ebx, ebx         ; Y^2
    cdq
    idiv ebx              ; -(X/Y + 1) / Y^2
    jmp print_result

eq4:
    ; Z = 1 + X^2 / 3Y
    mov eax, [x]
    imul eax, eax         ; X^2
    mov ebx, [y]
    imul ebx, 3           ; 3Y
    cdq
    idiv ebx              ; X^2 / 3Y
    add eax, 1            ; 1 + X^2 / 3Y
    jmp print_result

eq5:
    ; Z = Y - X/3 + 1
    mov eax, [x]
    cdq
    idiv dword [div_three] ; X / 3
    mov ebx, [y]
    sub ebx, eax          ; Y - X / 3
    add ebx, 1            ; Y - X / 3 + 1
    mov eax, ebx
    jmp print_result

print_result:
    mov [z], eax          ; сохраняем результат в z
    mov eax, 4
    mov ebx, 1
    mov ecx, result_msg
    mov edx, 11
    int 0x80

    call print_number
    jmp exit

input_number:
    ; Ввод числа с консоли
    mov eax, 3            ; sys_read
    mov ebx, 0            ; stdin
    mov ecx, number_buf   ; буфер для ввода
    mov edx, 12           ; максимальная длина ввода
    int 0x80

    ; Преобразование строки в число
    xor eax, eax
    xor esi, esi          ; индекс для чтения строки

parse_loop:
    movzx ebx, byte [number_buf + esi]
    cmp ebx, 10           ; проверка на новую строку
    je done_parse
    sub ebx, '0'
    imul eax, eax, 10
    add eax, ebx
    inc esi
    jmp parse_loop

done_parse:
    ret

print_number:
    ; Преобразование числа в строку и вывод
    mov eax, [z]
    call int_to_string

    ; Вывод числа
    mov eax, 4
    mov ebx, 1
    ; mov ecx, number_buf
    mov edx, 12
    int 0x80
    ret

print_newline:
    ; печатаем новую строку
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80
    ret

int_to_string:
    ; Преобразование числа в строку
    mov esi, number_buf   ; указатель на буфер
    add esi, 11           ; начнем с конца буфера
    mov byte [esi], 0     ; завершающий нулевой символ
    dec esi

    ; Проверка на отрицательное число
    mov ebx, eax          ; сохраняем значение для преобразования
    test eax, eax         ; проверяем знак числа
    jns positive_number   ; если положительное, пропускаем

    ; Обработка отрицательного числа
    neg eax               ; делаем число положительным для преобразования
    ; mov byte [esi], '-'   ; записываем знак минус
    ; dec esi
    push eax
    push ebx

    mov eax, 4
    mov ebx, 1
    mov ecx, minus
    mov edx, 1
    int 0x80
    pop ebx
    pop eax

positive_number:
convert_digit:
    xor edx, edx
    div dword [div_ten]
    add dl, '0'
    mov [esi], dl
    dec esi
    test eax, eax
    jnz convert_digit
    inc esi
    mov ecx, esi
    ret

exit:
    mov eax, 1            ; sys_exit
    xor ebx, ebx
    int 0x80
