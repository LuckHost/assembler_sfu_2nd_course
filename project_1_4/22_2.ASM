format PE Console      ; Формат файла - исполняемый файл для консоли
entry start            ; Точка входа программы

include 'win32a.inc'   ; Подключение файла, содержащего определения для работы с Win32 API

section '.data' data readable writeable   ; Секция данных программы (чтение/запись)

        struct welder                    ; Определение структуры welder (сварщик)
            name db 30 dup(0)            ; Поле для имени, 30 байт, заполнено нулями
            surname db 30 dup(0)         ; Поле для фамилии, 30 байт, заполнено нулями
            patronymic db 30 dup(0)      ; Поле для отчества, 30 байт, заполнено нулями
            discharge dd 0               ; Поле для разряда (целое число 4 байта)
        ends                             ; Конец структуры

        welders welder ?,?,?,?           ; Объявление массива из 5 сварщиков с инициализацией по умолчанию
                welder ?,?,?,?
                welder ?,?,?,?
                welder ?,?,?,?
                welder ?,?,?,?

        string_input db '%s',0           ; Формат для ввода строки
        int_output db '%d',10,0          ; Формат для вывода числа
        struct_output db '%s, %s, %s, %d',10,0  ; Формат для вывода данных сварщика (имя, фамилия, отчество, разряд)

        n dd 5                           ; Количество сварщиков
        size_of dd 94                    ; Размер одной структуры welder в байтах
        i dd 0                           ; Счетчик цикла

        read_file_name db 'in',0         ; Имя файла для чтения
        write_file_name db 'out',0       ; Имя файла для записи
        w_mode db 'w',0                  ; Режим открытия файла для записи
        r_mode db 'r',0                  ; Режим открытия файла для чтения
        read_file_d dd 0                 ; Дескриптор файла для чтения
        write_file_d dd 0                ; Дескриптор файла для записи
        size dd 0                        ; Переменная для хранения промежуточных размеров

section '.code' code readable writeable executable   ; Секция кода программы

start:
        invoke fopen, read_file_name, r_mode    ; Открытие файла для чтения
        mov [ds:read_file_d], eax               ; Сохранение дескриптора файла

        mov eax, [ds:n]                         ; Загружаем количество сварщиков
        imul [ds:size_of]                       ; Вычисляем общий размер данных для чтения (количество сварщиков * размер одного сварщика)
        mov ecx, 1                              ; Указываем, что считываем один блок

        invoke fread, welders, ecx, eax, [ds:read_file_d] ; Считываем данные из файла

        invoke fclose, [ds:read_file_d]         ; Закрываем файл для чтения

        invoke fopen, write_file_name, w_mode   ; Открываем файл для записи
        mov [ds:write_file_d], eax              ; Сохраняем дескриптор файла для записи

        mov [ds:i], 0                           ; Инициализируем счетчик i
        looop2:
                mov eax, [ds:i]                 ; Загружаем значение счетчика i
                imul [ds:size_of]               ; Вычисляем смещение для текущего сварщика

                mov edx, eax                    ; Загружаем смещение в edx
                add edx, welders.discharge       ; Смещаем указатель на поле discharge в структуре сварщика

                push eax                        ; Сохраняем eax в стеке
                mov eax, 1                      ; Устанавливаем значение 1
                sub [edx], eax                  ; Уменьшаем разряд сварщика на 1
                pop eax                         ; Восстанавливаем значение eax

                inc [ds:i]                      ; Увеличиваем счетчик i
                mov edx, [ds:i]                 ; Загружаем новое значение счетчика
                cmp edx, 5                      ; Проверяем, не достигли ли мы 5 сварщиков
                jne looop2                      ; Если нет, продолжаем цикл

        mov eax, [ds:n]                         ; Загружаем количество сварщиков
        imul [ds:size_of]                       ; Вычисляем общий размер данных для записи
        mov ecx, 1                              ; Устанавливаем количество блоков для записи

        mov [ds:i], 0                           ; Сбрасываем счетчик i
        looop:
                mov eax, [ds:i]                 ; Загружаем значение счетчика i
                imul [ds:size_of]               ; Вычисляем смещение для текущего сварщика
                mov [ds:size], eax              ; Сохраняем смещение

                mov ebx, [ds:size]              ; Загружаем смещение в ebx
                add ebx, welders.name           ; Смещаем указатель на поле name

                mov ecx, [ds:size]              ; Загружаем смещение в ecx
                add ecx, welders.surname        ; Смещаем указатель на поле surname

                add eax, welders.patronymic     ; Смещаем указатель на поле patronymic

                mov edx, [ds:size]              ; Загружаем смещение в edx
                add edx, welders.discharge      ; Смещаем указатель на поле discharge

                invoke printf, struct_output, ebx, ecx, eax, [edx] ; Выводим информацию о текущем сварщике

                inc [ds:i]                      ; Увеличиваем счетчик i
                mov edx, [ds:i]                 ; Загружаем новое значение счетчика
                cmp edx, 3                      ; Проверяем, не достигли ли мы 3 сварщиков
                jne looop                       ; Если нет, продолжаем цикл

        mov eax, [ds:size_of]                   ; Загружаем размер структуры
        mov ecx, [ds:n]                         ; Загружаем количество сварщиков
        invoke fwrite, welders, eax, ecx, [ds:write_file_d] ; Записываем данные в файл

        invoke fclose, [ds:write_file_d]        ; Закрываем файл для записи

        invoke getch                            ; Ожидаем нажатие клавиши
        invoke ExitProcess, 0                   ; Завершаем выполнение программы

section '.idata' data import readable           ; Секция для импорта функций из библиотек
  library kernel, 'kernel32.dll',\              ; Импорт библиотеки kernel32.dll
                msvcrt, 'msvcrt.dll'            ; Импорт библиотеки msvcrt.dll
  
  import kernel,\                               ; Импортируемая функция ExitProcess из kernel32.dll
         ExitProcess, 'ExitProcess'

  import msvcrt,\                               ; Импортируемые функции из msvcrt.dll
          printf, 'printf',\
          getch, '_getch', scanf, 'scanf', fopen, 'fopen', fwrite, 'fwrite', fclose, 'fclose', fread, 'fread'
