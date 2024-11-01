.globl __start

.data
maxItem:         .word -1000
minItem:         .word 1000
currentRow:      .word 0
array:           .word 0, 0, 0, 0, 0, 0, 0, 0, 0    # 9 zeros for the array

O_READONLY:      .word 1
path:            .string "E:/Programming/assembler_sfu_2nd_course/project_2_2/random_numbers.txt"
size_arr:        .word 9
N:               .word 3
item_msg:        .string "Min in row is: "
item_msg_max:    .string "Max out of min is: "

.text

func:
    mv t1, a0            # t1: address of input array
    li t3, 0             # t3: current row
arr_row:
    lw t2, N
    li t4, 0             # t4: current column
    
arr_col:
    mv t5, t3            # t5: offset
    mul t5, t5, t2
    add t5, t5, t4

    mv t0, t1
    add t0, t0, t5
    lb t6, 0(t0)         # t6 - current element

    # Compare current element with minimum element in the row
    la a1, minItem
    lw t0, 0(a1)
    
    bge t6, t0, not_min_row
    sw t6, 0(a1)

not_min_row:
    addi t4, t4, 1
    blt t4, t2, arr_col

    li a0, 4             # 4 - syscall for printing string
    la a1, item_msg
    ecall

    li a0, 1             # 1 - syscall for printing integers
    lw a1, minItem
    ecall

    li a0, 11
    li a1, '\n'
    ecall

    la a1, maxItem
    la a4, minItem
    lw t5, 0(a1)         # t5 = max
    lw t0, 0(a4)         # t0 = min
    
    blt t0, t5, not_new_max
    sw t0, 0(a1)

not_new_max:
    # Update minimum value for each row
    la a1, minItem
    li t6, 1000
    sw t6, 0(a1)
    
    # Move to the next row
    addi t3, t3, 1
    lw t0, N
    blt t3, t0, arr_row

    li a0, 4             # 4 - syscall for printing string
    la a1, item_msg_max
    ecall

    li a0, 1             # 1 - syscall for printing integers
    lw a1, maxItem
    ecall  

    li a0, 11
    li a1, '\n'
    ecall
    
    li a0, 11
    li a1, '\n'
    ecall
    ret

print_arr:
    mv t1, a0            # t1: address of input array
    li t3, 0             # t3: current row
print_arr_row:
    lw t2, N
    li t4, 0             # t4: current column
print_arr_col:
    mv t5, t3            # t5: offset
    mul t5, t5, t2
    add t5, t5, t4
    
    mv  t0, t1
    add t0, t0, t5
    lb t6, 0(t0)

    li a0, 1             # 1 - syscall for printing integer
    mv a1, t6
    ecall   
    li a0, 11
    li a1, ' '
    ecall
    
    addi t4, t4, 1
    blt t4, t2, print_arr_col

    li a0, 11           # Move to next row
    li a1, '\n'
    ecall

    addi t3, t3, 1
    lw t0, N
    blt t3, t0, print_arr_row
    
    li a0, 11
    li a1, '\n'
    ecall
    ret

__start:
    li a0, 1024         # 1024 - open syscall (Linux ABI for RISC-V)
    la a1, path
    lw a2, O_READONLY   # Read-only
    ecall
    mv s0, a0           # s0 - file descriptor
  
    li a0, 63           # 63 - read syscall (Linux ABI for RISC-V)
    mv a1, s0
    la a2, array
    lw a3, size_arr
    ecall

    la a0, array
    call print_arr
  
    la a0, array
    call func           # main task
  
    li a0, 93           # 93 - exit syscall (Linux ABI for RISC-V)
    ecall


exit_program:
    li a0, 93            # Exit syscall code
    ecall
