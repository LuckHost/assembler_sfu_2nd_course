format PE Console

entry start

include 'win32a.inc'

section '.data' data readable writeable

        source db 1000 dup(0),0               ; Буфер для ввода строки размером 1000 байт
        source_addr dd source                 ; Адрес начала буфера source
        target db 1000 dup(0),0               ; Буфер для вывода строки (копия) размером 1000 байт
        target_addr dd target                 ; Адрес начала буфера target
        format_input db '%999[^\',10,']',0    ; Формат строки для чтения с клавиатуры до символа новой строки
        format_output db '%s',10,0            ; Формат вывода строки
        output_int db '%d',10,0               ; Формат для вывода целого числа
        output_reg db '%d %d %d %d',10,0      ; Формат вывода четырёх целых чисел

section '.code' code readable writeable executable

start:
        ; Чтение строки с клавиатуры в буфер source
        invoke scanf, format_input, source

        ; Перевод процессора в состояние работы с обратным направлением (для строки)
        std

        ; Поиск конца строки, начиная с конца буфера
        mov edi, source + 999                 ; Начинаем с последнего байта буфера
        mov al, 0                             ; Ищем символ нуля (окончание строки)
        mov ecx, 1000                         ; Устанавливаем длину строки
        repe scasb                            ; Ищем конец строки (нулевой байт)
        ; Теперь ecx содержит количество оставшихся символов после нахождения конца строки

        ; Поиск пробела
        mov al, ' '                           ; Ищем пробел
        repe scasb                            ; Повторяем поиск пробела в обратном направлении
        ; Теперь ecx содержит количество символов до пробела

        ; Поиск символа, отличного от пробела
        repne scasb                           ; Ищем символ, отличный от пробела
        ; Теперь ecx содержит количество символов до первого ненулевого символа (не пробела)

        ; Устанавливаем направление вперёд для копирования
        cld

        ; Копирование строки из буфера source в target
        mov esi, source                       ; Адрес исходного буфера
        mov edi, target                       ; Адрес целевого буфера
        rep movsb                             ; Копируем строку (байт за байтом)

        ; Вывод результата (буфер target)
        invoke printf, format_output, target

        ; Ожидание нажатия клавиши перед завершением программы
        invoke getch
        ; Завершение программы
        invoke ExitProcess, 0

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
