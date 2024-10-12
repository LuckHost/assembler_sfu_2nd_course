format PE Console

entry start

include 'win32a.inc'

section '.data' data readable writeable
        output_int db '%4d ',0                ; Формат для вывода целого числа с шириной поля 4
        output_registers db '%d %d %d %d',10,0; Формат для вывода четырёх целых чисел с переводом строки
        output2 db '%d %d',10,0               ; Формат для вывода двух целых чисел с переводом строки
        newline db 10,0                       ; Символ новой строки

        array dd 10 dup 0                     ; Массив из 10 элементов, инициализированных 0
        R_arr dd 10 dup 0                     ; Массив для результатов, также 10 элементов
        len dd 9                              ; Длина массива - 9 элементов
        size dd 3                             ; Размер группы для обработки - 3

section '.code' code readable writeable executable

start:
        ; Инициализация генератора случайных чисел
        invoke time, 0                        ; Получить текущее время
        invoke srand, eax                     ; Инициализировать генератор случайных чисел значением времени

        ; Заполнение массива случайными числами
        mov ebx, [ds:size]                    ; ebx = 3 (размер группы)
        imul ebx, [ds:size]                   ; ebx = 9 (размер массива)
        loopfill:
                cmp ebx, 0                    ; Проверка окончания цикла
                je loopfillend                 ; Если ebx = 0, завершить цикл
                invoke rand                    ; Получить случайное число
                cdq                            ; Расширение знака
                mov ecx, 100                   ; Модуль 100 для получения числа от 0 до 99
                idiv ecx                       ; Деление на 100, результат в edx
                mov [ds:array + 4 * ebx-4], edx; Запись случайного числа в массив

                dec ebx                        ; Уменьшить счетчик
                jmp loopfill                   ; Повторить цикл
       loopfillend:

       ; Вывод массива
        mov ebx, 0                            ; ebx = 0 (индекс для массива)
        loopprint1:
                cmp ebx, [ds:len]              ; Сравнение с длиной массива
                je act                         ; Если достигли конца массива, перейти к действию
                invoke printf, output_int, [ds:array + 4 * ebx] ; Вывод значения из массива
                inc ebx                        ; Увеличить индекс

                ; Проверка на кратность "size" для вывода новой строки
                mov eax, ebx                   ; eax = индекс ebx
                cdq                            ; Расширение знака
                idiv [ds:size]                 ; Деление на "size"
                cmp edx, 0                     ; Если остаток = 0, печатаем новую строку
                jnz loopprint1

                invoke printf, newline         ; Вывод новой строки

                jmp loopprint1                 ; Повтор цикла вывода

act:
        ; Логика работы с элементами массива
        mov ebx, 0                            ; Начальный индекс ebx = 0
        mov ecx, 0                            ; ecx = 0 (элемент)
        mov eax, 0                            ; eax = 0 (элемент)
        mov edx, 0                            ; edx = 0 (элемент)

        ; Записываем первое значение в результирующий массив
        mov eax, [ds:array + 4 * ebx]         ; Берем первый элемент массива
        mov [ds:R_arr + 4 * ebx], eax         ; Копируем его в результирующий массив

        inc ebx                               ; Переход к следующему элементу
        mov ecx, [ds:array + 4 * ebx]         ; Считываем первый элемент (1-й)
        mov edx, ecx                          ; Сохраняем в edx
        mov ecx, [ds:array + 4 * (ebx + 2)]   ; Считываем 3-й элемент
        cmp edx, ecx                          ; Сравниваем 1-й и 3-й элементы
        jge add_1                             ; Если 1-й >= 3-го, переход к добавлению первого элемента
        mov [ds:R_arr + 4 * ebx], ecx         ; Иначе копируем 3-й элемент в результирующий массив
        jmp trn_2

trn_2:
        ; Работа со следующими элементами
        inc ebx
        mov ecx, [ds:array + 4 * ebx]         ; Считываем 2-й элемент
        mov edx, ecx                          ; Сохраняем в edx

        mov ecx, [ds:array + 4 * (ebx + 2)]   ; Считываем 4-й элемент
        mov eax, ecx                          ; Сохраняем его в eax

        mov ecx, [ds:array + 4 * (ebx + 4)]   ; Считываем 6-й элемент
        cmp edx, eax                          ; Сравниваем 2-й и 4-й элементы
        jge add_2                             ; Если 2-й >= 4-го, перейти к добавлению
        cmp eax, ecx                          ; Сравниваем 4-й и 6-й элементы
        jge add_3                             ; Если 4-й >= 6-го, добавить 4-й элемент
        mov [ds:R_arr + 4 * ebx], ecx         ; Иначе копируем 6-й элемент
        jmp trn_3

trn_3:
        inc ebx
        mov ecx, [ds:array + 4 * (ebx + 2)]   ; Считываем 5-й элемент
        mov edx, ecx

        mov ecx, [ds:array + 4 * (ebx + 4)]   ; Считываем 7-й элемент
        cmp edx, ecx                          ; Сравниваем 5-й и 7-й элементы
        jge add_4
        mov [ds:R_arr + 4 * ebx], ecx         ; Если 7-й больше, копируем его

        inc ebx
        mov ecx, [ds:array + 4 * (ebx + 4)]   ; Считываем 8-й элемент
        mov [ds:R_arr + 4 * ebx ], ecx        ; Копируем его
        jmp res

add_1:
        ; Добавление 1-го элемента в результирующий массив
        mov [ds:R_arr + 4 * ebx ], edx
        jmp trn_2

add_2:
        ; Добавление 2-го элемента в результирующий массив
        cmp edx, ecx
        jge add_dd
        mov [ds:R_arr + 4 * ebx], ecx
        jmp trn_3
add_dd:
        mov [ds:R_arr + 4 * ebx], edx
        jmp trn_3

add_3:
        ; Добавление 4-го элемента
        mov [ds:R_arr + 4 * ebx], eax
        jmp trn_3

add_4:
        ; Добавление 5-го элемента
        mov [ds:R_arr + 4 * ebx], edx
        inc ebx
        mov ecx, [ds:array + 4 * (ebx + 4)]   ; 8-й элемент
        mov [ds:R_arr + 4 * ebx ], ecx        ; Копирование 8-го элемента
        jmp res

res:
        ; Вывод результирующего массива
        invoke printf, newline
        mov ebx, 0                            ; ebx = 0 (индекс для массива)
        loopprintR:
              cmp ebx, 5                      ; Выводим только первые 5 элементов
              je endd                         ; Переход к завершению, если индекс = 5
              invoke printf, output_int, [ds:R_arr + 4 * ebx] ; Вывод результата
              inc ebx                         ; Увеличить индекс
              jmp loopprintR
        jmp endd

endd:
        ; Ожидание нажатия клавиши и завершение программы
        invoke getch                          ; Ожидание нажатия клавиши
        invoke ExitProcess, 0                 ; Завершение программы

section '.idata' data import readable
        ; Импорт библиотек kernel32.dll и msvcrt.dll
        library kernel, 'kernel32.dll',\
                msvcrt, 'msvcrt.dll'
  
  ; Импорт функций из библиотек
  import kernel,\
                                ExitProcess, 'ExitProcess'
          
  import msvcrt,\
                                printf, 'printf',\
          getch, '_getch', scanf, 'scanf', rand, 'rand', srand, 'srand', time, 'time', malloc, 'malloc'
