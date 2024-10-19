                    format PE Console

entry start

include 'win32a.inc'

section '.data' data readable writeable

        struct welder
            name db 30 dup(0)
            surname db 30 dup(0)
            patronymic db 30 dup(0)
            discharge dd 0
        ends
        welders welder 'Alex','Ostin','Danilovich',4
                welder 'Sam','Ospov','Sergeevich',5
                welder 'Din','Kim','Alekseevich',3
        string_input db '%s',0
        int_output db '%d',15,0
        n dd 5
        size_of dd 94

        write_file_name db 'in',0
        w_mode db 'w',0
        file_d dd 0

section '.code' code readable writeable executable

start:
        invoke fopen, write_file_name, w_mode
        ; дескриптор файла
        mov [ds:file_d], eax
        mov eax, [ds:n]
        imul [ds:size_of]
        mov ecx, 1
        invoke fwrite, welders, ecx, eax, [ds:file_d]
        invoke fclose, [ds:file_d]


        invoke getch
        invoke ExitProcess, 0

section '.idata' data import readable
  library kernel, 'kernel32.dll',\
                msvcrt, 'msvcrt.dll'
  
  import kernel,\
         ExitProcess, 'ExitProcess'

          
  import msvcrt,\
          printf, 'printf',\
          getch, '_getch', scanf, 'scanf', fopen, 'fopen', fwrite, 'fwrite', fclose, 'fclose'