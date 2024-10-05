format PE Console

entry start

include 'win32a.inc'

section '.data' data readable writeable
    ; Определение данных, которые будут использоваться в программе

    InputX db 'Enter X value:',0          ; Сообщение для ввода X
    InputA db 'Enter A value:',0          ; Сообщение для ввода A
    input db '%lf',0                      ; Формат для ввода числа с плавающей точкой
    output_y1 db 'y1 = %5.3f',10,0        ; Формат вывода y1
    output_y2 db 'y2 = %5.3f',10,0        ; Формат вывода y2
    output_y db 'y  = %5.3f',10,0         ; Формат вывода y
    newline db '',10,0                    ; Символ новой строки
    a dq ?                                ; Переменная для хранения A (64-битное число)
    x dq ?                                ; Переменная для хранения X (64-битное число)
    y1 dq ?                               ; Переменная для y1
    y2 dq ?                               ; Переменная для y2
    y dq ?                                ; Переменная для результата y (y1 + y2)
    i dd 0                                ; Счетчик цикла
    n dd 10                               ; Количество итераций цикла
    temp dd 0                             ; Временная переменная
    NULL = 0                              ; Определение NULL
    zero dq 0.0                           ; Переменная для хранения значения 0.0 (используется для сравнения)

section '.code' code readable writeable executable

start:
    ; Начало программы

    push InputX                           ; Выводим сообщение для ввода X
    call [printf]

    invoke scanf, input, x                ; Вводим значение X с клавиатуры

    push InputA                           ; Выводим сообщение для ввода A
    call [printf]

    invoke scanf, input, a                ; Вводим значение A с клавиатуры
    invoke printf, newline                ; Переход на новую строку

lp:
    ; Начало цикла, который будет выполняться 10 раз

    finit                                 ; Инициализация FPU (чтобы работать с числами с плавающей точкой)
    fld qword [ds:x]                      ; Загружаем значение X в FPU
    fabs                                  ; Берем модуль X
    mov [ds:temp], 3                      ; Загружаем значение 3 в temp
    fild dword [ds:temp]                  ; Загружаем 3 в FPU для сравнения
    fcomip st1                            ; Сравниваем |X| с 3
    jbe else_1                            ; Переход, если |X| <= 3

if_1:
    ; Если |X| > 3, то y1 = 4 - X
    fld qword [ds:x]                      ; Загружаем X
    mov [ds:temp], 4                      ; Загружаем 4 в temp
    fild dword [ds:temp]                  ; Загружаем 4 в FPU
    fsub qword [ds:x]                     ; Выполняем операцию 4 - X
    fstp [ds:y1]                          ; Сохраняем результат в y1
    jmp if_1_out                          ; Переход за пределы условия

else_1:
    ; Если |X| <= 3, то y1 = A + X
    fld qword [ds:a]                      ; Загружаем A
    fadd qword [ds:x]                     ; Складываем A + X
    fstp [ds:y1]                          ; Сохраняем результат в y1
if_1_out:

    ; Вторая часть вычислений (вычисление y2)
    finit                                 ; Снова инициализация FPU
    mov [ds:temp], 2                      ; Загружаем 2 в temp
    fild dword [ds:temp]                  ; Загружаем 2 в FPU
    fld qword [ds:x]                      ; Загружаем X
    fprem                                 ; Выполняем операцию остатка от деления X на 2
    mov [ds:temp], 0                      ; Загружаем 0 в temp
    fild dword [ds:temp]                  ; Загружаем 0 в FPU
    fcomip st1                            ; Сравниваем результат fprem с 0
    je else_2                             ; Если результат равен 0, то переходим к else_2

if_2:
    ; Если остаток от деления не равен 0, то y2 = A + 2
    fld qword [ds:a]                      ; Загружаем A
    mov [ds:temp], 2                      ; Загружаем 2
    fild dword [ds:temp]                  ; Загружаем 2 в FPU
    faddp                                 ; Складываем A + 2
    fstp [ds:y2]                          ; Сохраняем результат в y2
    jmp if_2_out                          ; Переход за пределы условия

else_2:
    ; Если остаток от деления равен 0, то y2 = 2
    mov [ds:temp], 2                      ; Загружаем 2
    fild dword [ds:temp]                  ; Загружаем 2 в FPU
    fstp [ds:y2]                          ; Сохраняем результат в y2
if_2_out:

    ; Вычисление окончательного значения y
    fld qword [ds:y1]                     ; Загружаем y1
    fadd qword [ds:y2]                    ; Складываем y1 + y2
    fstp [ds:y]                           ; Сохраняем результат в y

    ; Вывод значений y1, y2, y
    invoke printf, output_y1, dword [ds:y1], dword [ds:y1+4]   ; Выводим y1
    invoke printf, output_y2, dword [ds:y2], dword [ds:y2+4]   ; Выводим y2
    invoke printf, output_y, dword [ds:y], dword [ds:y+4]      ; Выводим y
    invoke printf, newline                ; Переход на новую строку

    ; Увеличиваем значение X на 1
    fld1                                  ; Загружаем 1 в FPU
    fadd qword [ds:x]                     ; Выполняем X = X + 1
    fstp [ds:x]                           ; Сохраняем обновленное значение X

    ; Увеличиваем счетчик i и проверяем, завершился ли цикл
    mov ecx, [ds:i]                       ; Загружаем значение i
    inc ecx                               ; Увеличиваем i на 1
    cmp ecx, [ds:n]                       ; Сравниваем i с n (10)
    mov [ds:i], ecx                       ; Сохраняем обновленное значение i
    jne lp                                ; Если i < n, переходим на начало цикла

    ; Конец программы
    call [getch]                          ; Ждем нажатия клавиши
    push NULL                             ; Передаем NULL для завершения
    call [ExitProcess]                    ; Завершаем процесс

section '.idata' data import readable
    ; Определение секции для импорта функций из библиотек

    library kernel, 'kernel32.dll',\
            msvcrt, 'msvcrt.dll'

    import kernel,\
            ExitProcess, 'ExitProcess'

    import msvcrt,\
            printf, 'printf',\
            getch, '_getch', scanf, 'scanf'
