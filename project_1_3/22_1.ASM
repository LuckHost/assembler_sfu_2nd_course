format PE Console

entry start

include 'win32a.inc'

section '.data' data readable writeable
        output_int db '%4d ',0
        output_registers db '%d %d %d %d',10,0
        output2 db '%d %d',10,0
        newline db 10,0

        array dd 10 dup 0
        R_arr dd 10 dup 0
        len dd 9
        size dd 3

section '.code' code readable writeable executable

start:
        ;Установка сида для рандома
        invoke time, 0
        invoke srand, eax

        ;Заполнение случайными
        mov ebx, [ds:size]
        imul ebx, [ds:size]
        loopfill:
                cmp ebx, 0
                je loopfillend
                invoke rand
                cdq
                mov ecx, 100
                idiv ecx
                mov [ds:array + 4 * ebx-4], edx

                dec ebx
                jmp loopfill
       loopfillend:

       ;Вывод массива
        mov ebx, 0
        loopprint1:
                cmp ebx, [ds:len]
                je act
                invoke printf, output_int, [ds:array + 4 * ebx]
                inc ebx

                ;Проверка кратен ли индекс стороне массива
                mov eax, ebx
                cdq
                idiv [ds:size]
                cmp edx, 0
                jnz loopprint1

                invoke printf, newline

                jmp loopprint1

act:
        mov ebx, 0      ; ebx = 0 (index for array)
        mov ecx, 0      ; ecx = 0 (element)
        mov eax, 0      ; eax = 0 (element)
        mov edx, 0      ; edx = 0 (element)

        mov eax, [ds:array + 4 * ebx]
        mov [ds:R_arr + 4 * ebx], eax   ;adding first num

        inc ebx
        mov ecx, [ds:array + 4 * ebx] ; 1-st element
        mov edx, ecx
        ;invoke printf, output_int, edx
        mov ecx, [ds:array + 4 * (ebx + 2)]   ; 3-rd element
        ;invoke printf, output_int, ecx
        ;invoke printf, newline

        cmp edx, ecx
        jge add_1
        mov [ds:R_arr + 4 * ebx], ecx
        jmp trn_2

trn_2:

                inc ebx
                mov ecx, [ds:array + 4 * ebx] ; 2-nd element
                mov edx, ecx ; edx = 2-nd element

                mov ecx, [ds:array + 4 * (ebx + 2)]   ;4-th element
                mov eax, ecx       ; eax = 4-th element

                mov ecx, [ds:array + 4 * (ebx + 4)] ; ecx = 6-th element

                cmp edx, eax
                jge add_2
                cmp eax, ecx
                jge add_3
                mov [ds:R_arr + 4 * ebx], ecx
                jmp trn_3

trn_3:
                inc ebx
                mov ecx, [ds:array + 4 * (ebx + 2)] ; 5-th element
                mov edx, ecx

                mov ecx, [ds:array + 4 * (ebx + 4)] ; 7-th element

                cmp edx, ecx
                jge add_4
                mov [ds:R_arr + 4 * ebx], ecx

                inc ebx
                mov ecx, [ds:array + 4 * (ebx + 4)] ; 8-th element
                mov [ds:R_arr + 4 * ebx ], ecx
                jmp res


add_1:
        mov [ds:R_arr + 4 * ebx ], edx
        jmp trn_2


add_2:
        cmp edx, ecx
        jge add_dd
        mov [ds:R_arr + 4 * ebx], ecx
        jmp trn_3
        add_dd:
                mov [ds:R_arr + 4 * ebx], edx
                jmp trn_3
add_3:
        mov [ds:R_arr + 4 * ebx], eax
        jmp trn_3

add_4:
        mov [ds:R_arr + 4 * ebx], edx
        inc ebx
        mov ecx, [ds:array + 4 * (ebx + 4)] ; 8-th element
        mov [ds:R_arr + 4 * ebx ], ecx
        jmp res

res:
        invoke printf, newline
        mov ebx, 0                  ; ebx = 0 (index for array)
        loopprintR:
              cmp ebx, 5
              je endd
              invoke printf, output_int, [ds:R_arr + 4 * ebx]
              inc ebx
              jmp loopprintR
        jmp endd


endd:
        invoke getch
        invoke ExitProcess, 0

section '.idata' data import readable
        library kernel, 'kernel32.dll',\
                msvcrt, 'msvcrt.dll'
  
  import kernel,\
                                ExitProcess, 'ExitProcess'
          
  import msvcrt,\
                                printf, 'printf',\
          getch, '_getch', scanf, 'scanf', rand, 'rand', srand, 'srand', time, 'time', malloc, 'malloc'