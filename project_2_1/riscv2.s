.data

input_a:
    .string "Input A\n"
input_x:
    .string "Input X\n"
new_line:
    .string "\n"
    
print_y1:
    .string "Y1 = "
print_y2:
    .string ", Y2 = "
print_y:
    .string "Y = "
  
.text
    .global __start


__start:
    # Напечатать строку 
    li a7, 4
    la a0, input_a
    ecall
    
    # Ввод int
    li a7, 5
    ecall
    
    # Переместить A в t1
    mv t1, a0
    
    # Напечатать строку
    li a7, 4
    la a0, input_x
    ecall
    
    # Ввод int
    li a7, 5
    ecall
    
    # Переместить X в t2
    mv t2, a0
    
    # Индекс t0 = 0
    li t0, 0

loop:
    # Если X больше 4 то over_4
    li t5, 4    # t5 = 4
    bge t5, t2, less_or_eq_4 # if 4 >= X ==> 4 * X
    ble t5, t2, bigger_than_4 # if 4 < X ==> X - A
    
less_or_eq_4:
    mul s1, t5, t2
    j continue    

bigger_than_4:
    sub s1, t2, t1
  
continue:
    li t6, 2    # t6 = 2
    rem t4, t2, t6
    beqz t4, even
    j not_even

not_even:
    li t6, 7    # t6 = 7
    mv s2, t6 
    j result
  
even:
    li t6, 2    # t6 = 2
    rem s2, t2, t6
    add s2, s2, t1
    
result:
    # Вывести строку
    li a7, 4
    la a0, print_y1
    ecall
    
    # Вывести s1 - Y1
    li a7, 1
    mv a0, s1
    ecall
    
    # Вывести строку
    li a7, 4
    la a0, print_y2
    ecall
    
    # Вывести s2 - Y2
    li a7, 1
    mv a0, s2
    ecall
    
    # Вывести \n
    li a7, 4
    la a0, new_line
    ecall
    
    add s3, s1, s2
    
    # Вывести строку 
    li a7, 4
    la a0, print_y
    ecall
    
    # Вывести s3 - Y
    li a7, 1
    mv a0, s3
    ecall
    
    # Вывести \n
    li a7, 4
    la a0, new_line
    ecall
    
    # Увеличить X на 1
    addi t2, t2, 1
    
    # Положить 9 в t4
    li t4, 9
    # Увеличить индекс
    addi t0, t0, 1
    # Если индекс не равен 9 - перейти на loop
    bne t0, t4, loop
    
    # Завершение программы
    li a7, 10
    ecall  
