global main

extern scanf
extern printf

section .data
    message1: db "Enter A: ", 10, 0
    message2: db "Enter X: ", 10, 0
    formatin: db "%f", 0
    formatout: db "Y = %f", 10, 0
    printX: db "X = %f", 10, 0

    A: dd 0.0
    X: dd 0.0
    Y1: dd 0.0
    Y2: dd 0.0
    Y: dd 0.0

section .text
main:
    finit                   ; Инициализация FPU
    ; Ввод A
    push message1
    call printf
    add esp, 4
    push A
    push formatin
    call scanf
    add esp, 8

    ; Ввод X
    push message2
    call printf
    add esp, 4
    push X
    push formatin
    call scanf
    add esp, 8

    ; Основной цикл, X меняется с шагом 1, повторяется 10 раз
    mov ecx, 10
    cycle_start:
        ; Вызов calcY1
        call calcY1
        
        ; Вызов calcY2
        call calcY2

        ; Проверка Y2 на ноль перед вычислением Y
        fld dword [Y2]
        fldz                    ; Загружаем 0
        fcom                    ; Сравниваем Y2 с 0
        fstsw ax
        sahf
        je skip_output           ; Пропускаем вывод, если Y2 == 0

        ; Вызов calcY
        call calcY
        
        ; Ограничение значений для Y
        fld dword [Y]
        fabs                   ; Берем абсолютное значение Y
        fld qword [max_value]   ; Максимальное значение для проверки
        fcom                    ; Сравниваем
        fstsw ax
        sahf
        ja skip_output          ; Если Y слишком велико, пропускаем вывод

        ; Вывод результата Y
        push dword [Y]
        push formatout
        call printf
        add esp, 8

        ; Вывод текущего X
        push dword [X]
        push printX
        call printf
        add esp, 8

    skip_output:
        ; Увеличение X на 1
        fld dword [X]
        fld1                    ; Добавляем 1 к X
        fadd
        fstp dword [X]

        loop cycle_start         ; Переход к следующей итерации цикла

    ; Завершение программы
    ret

calcY1:
    fld dword [X]
    fld1
    fcom
    fstsw ax
    sahf
    ja greater_than_1

    ; Если X <= 1, то Y1 = |X| + A
    fld dword [X]
    fabs
    fld dword [A]
    fadd
    fstp dword [Y1]
    ret

greater_than_1:
    ; Если X > 1, то Y1 = 10 + X
    fld dword [X]
    fld qword [ten]             ; Загружаем число 10
    fadd
    fstp dword [Y1]
    ret

calcY2:
    fld dword [X]
    fld qword [four]            ; Загружаем число 4
    fcom
    fstsw ax
    sahf
    ja greater_than_4

    ; Если X <= 4, то Y2 = X
    fld dword [X]
    fstp dword [Y2]
    ret

greater_than_4:
    ; Если X > 4, то Y2 = 2
    fld qword [two]
    fstp dword [Y2]
    ret

calcY:
    fld dword [Y1]
    fld dword [Y2]

    ; Проверка на ноль, чтобы избежать деления на ноль
    fld dword [Y2]
    fldz                    ; Сравнение с нулем
    fcom
    fstsw ax
    sahf
    je skip_division        ; Если Y2 == 0, пропускаем

    fprem                  ; Остаток от деления Y1 на Y2
    fstp dword [Y]
    ret

skip_division:
    ; Если Y2 == 0, задаем Y как NaN (неопределенное значение)
    fldz                    ; Загружаем 0 в Y
    fstp dword [Y]
    ret

section .data
    ten: dd 10.0
    four: dd 4.0
    two: dd 2.0
    max_value: dd 1.0e20        ; Максимальное значение для Y
