format PE Console      ; Формат исполняемого файла для консольного приложения

entry start            ; Точка входа программы

include 'win32a.inc'   ; Подключение файла, содержащего определения для работы с Win32 API

section '.data' data readable writeable   ; Секция данных программы (разрешено чтение и запись)

        struct welder                    ; Определение структуры welder (сварщик)
            name db 30 dup(0)            ; Поле для имени, 30 байт, заполнено нулями
            surname db 30 dup(0)         ; Поле для фамилии, 30 байт, заполнено нулями
            patronymic db 30 dup(0)      ; Поле для отчества, 30 байт, заполнено нулями
            discharge dd 0               ; Поле для разряда (целое число 4 байта)
        ends                             ; Конец структуры

        welders welder 'Alex','Ostin','Danilovich',4   ; Инициализация первого сварщика с именем, фамилией, отчеством и разрядом
                welder 'Sam','Ospov','Sergeevich',5   ; Инициализация второго сварщика
                welder 'Din','Kim','Alekseevich',3    ; Инициализация третьего сварщика

        string_input db '%s',0           ; Формат для ввода строки
        int_output db '%d',15,0          ; Формат для вывода числа
        n dd 5                           ; Количество сварщиков
        size_of dd 94                    ; Размер одной структуры welder в байтах (30 + 30 + 30 + 4)

        write_file_name db 'in',0        ; Имя файла для записи данных
        w_mode db 'w',0                  ; Режим открытия файла для записи (write mode)
        file_d dd 0                      ; Дескриптор файла (переменная для хранения указателя на файл)

section '.code' code readable writeable executable   ; Секция кода программы

start:
        invoke fopen, write_file_name, w_mode    ; Открытие файла для записи
        mov [ds:file_d], eax                     ; Сохранение дескриптора файла в переменную

        mov eax, [ds:n]                          ; Загружаем количество сварщиков в регистр eax
        imul [ds:size_of]                        ; Вычисляем общий размер данных для записи (количество сварщиков * размер одной структуры)

        mov ecx, 1                               ; Указываем, что записываем один блок данных
        invoke fwrite, welders, ecx, eax, [ds:file_d]  ; Записываем данные массива welders в файл

        invoke fclose, [ds:file_d]               ; Закрываем файл

        invoke getch                             ; Ожидаем нажатие клавиши для завершения программы
        invoke ExitProcess, 0                    ; Завершаем выполнение программы с кодом выхода 0

section '.idata' data import readable            ; Секция для импорта функций из библиотек

  library kernel, 'kernel32.dll',\               ; Импорт библиотеки kernel32.dll
                msvcrt, 'msvcrt.dll'             ; Импорт библиотеки msvcrt.dll
  
  import kernel,\                                ; Импортируемая функция ExitProcess из kernel32.dll
         ExitProcess, 'ExitProcess'

  import msvcrt,\                                ; Импортируемые функции из msvcrt.dll
          printf, 'printf',\
          getch, '_getch', scanf, 'scanf', fopen, 'fopen', fwrite, 'fwrite', fclose, 'fclose'
