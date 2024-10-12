format PE Console

entry start

include 'win32a.inc'

section '.data' data readable writeable

        source db 1000 dup(0),0
        source_addr dd source
        target db 1000 dup(0),0
        target_addr dd target
        format_input db '%999[^\',10,']',0
        format_output db '%s',10,0
        output_int db '%d',10,0
        output_reg db '%d %d %d %d',10,0

section '.code' code readable writeable executable

start:
        invoke scanf, format_input, source
        std
        mov edi, source + 999
        mov al, 0
        mov ecx, 1000
        repe scasb
        ; ecx = индексу последнего символа
        mov al, ' '
        repe scasb
        ; ecx = индексу последнего непробельного
        repne scasb
        ; ecx = индексу перед последним словом

        cld
        mov esi, source
        mov edi, target
        rep movsb

        invoke printf, format_output, target


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