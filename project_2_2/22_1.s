.data
filename:   .string "/home/luckhost/programming/assembler_sfu_2nd_course/project_2_2/in.txt"  # ПУТЬ ФАЙЛА
array_size: .word 9                       # Размер массива
buffer:     .space 4                      # Буфер для чтения чисел из файла
new_line:   .string "\n"                  # Символ новой строки

.text
.globl _start

_start:
    # Открытие файла
    li      a7, 1024                      # Системный вызов open
    la      a0, filename                  # Путь к файлу
    li      a1, 0                         # Режим: только чтение
    ecall
    mv      s0, a0                        # Сохранение файлового дескриптора

    li      s2, 3                         # Количество строк (измените на реальное количество строк в файле)
    li      s1, 0x80000000                # Инициализация глобального максимума
    la      t1, buffer                    # Адрес буфера для чтения

find_min_max_loop:
    li      a4, 0x7FFFFFFF                # Инициализация минимума текущей строки
    li      t0, 3                         # Количество чисел в строке

inner_loop:
    # Чтение числа из файла
    mv      a0, s0                        # Файловый дескриптор
    la      a1, buffer                    # Указатель на буфер
    li      a2, 4                         # Размер данных для чтения
    li      a7, 63                        # Системный вызов read
    ecall

    # Проверка конца файла
    beqz    a0, end_loop

    # Считывание числа из буфера
    lw      a3, 0(a1)                     # Число из файла в a3

    # Сравнение и нахождение минимума
    blt     a3, a4, update_min
    j       check_next

update_min:
    mv      a4, a3                        # Обновление минимума текущей строки

check_next:
    addi    t0, t0, -1                    # Уменьшение счетчика чисел в строке
    bnez    t0, inner_loop                # Если числа остались, продолжить

    # Обновление глобального максимума
    bgt     a4, s1, update_global_max
    j       next_iteration

update_global_max:
    mv      s1, a4                        # Обновление глобального максимума

next_iteration:
    addi    s2, s2, -1                    # Уменьшение счетчика строк
    bnez    s2, find_min_max_loop         # Переход к следующей итерации, если строки остались

end_loop:
    # Вывод максимального значения среди минимальных
    li      a7, 1                         # Системный вызов print_int
    mv      a0, s1                        # Вывод результата
    ecall

    # Закрытие файла
    mv      a0, s0                        # Файловый дескриптор
    li      a7, 57                        # Системный вызов close
    ecall

    # Завершение программы
    li      a7, 93                        # Системный вызов exit
    li      a0, 0                         # Код завершения программы
    ecall
