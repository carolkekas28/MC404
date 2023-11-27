.bss
input: .skip 1
output: .skip 1

.text
.globl linked_list_search
linked_list_search:
/*a0: adress of head node
a1: sum we wish to find*/
    li t0, 0 # Our linked list starts on index 0
    loop_search:
        lw t1, 0(a0) 
        lw t2, 4(a0) # Load value1 and value2 
        add t3, t1, t2 # We add both numbers and store them in a3
        beq a1, t3, find # If its the same sum, we find the index and wil store it
        beqz t2, didnt_find # In case we reach the end of the linked list
        lw a0, 8(a0) # Next node
        addi t0, t0, 1 # We update index's value
        j loop_search
    
        didnt_find: 
            li a0, -1 # Return -1 if wished value was not find
            ret

        find:
            mv a0, t0
            ret 


.globl gets
gets: 
    mv t0, a0
    mv t4, a0

    loop_gets:
        li a0, 0  # File descriptor = 0 (stdin)
        la a1, input #  Buffer to write the data
        li a2, 1  # Reads one character at a time
        li a7, 63 # Syscall read (63)
        ecall

        la t1, input
        lb t2, 0(t1)

        li t3, 10 # Load '\n' value
        beq t2, t3, end_gets

        sb t2, 0(t0) # Stores char t2 on t0
        addi t0, t0, 1 # Move to next character 
        j loop_gets

    end_gets:
        li t1, 0
        sb t1, 0(t0)
        mv a0, t4 # Restoring adress of string to return it
        ret


.globl puts
puts:
    mv t2, a0 

    loop_puts:
        lbu t0, 0(t2)
        beqz t0, end_loop
        la t1, output
        sb t0, 0(t1)

        li a0, 1
        la a1, output
        li a2, 1
        li a7, 64
        ecall

        addi t2, t2, 1
        j loop_puts

    end_loop:
        li t0, 10
        sb t0, 0(t1)

        li a0, 1
        la a1, output
        li a2, 1
        li a7, 64
        ecall

        li a0, 0
        ret


.globl atoi
atoi:
    /*a0 has the adress of input string*/
    li t0, 0 # We are going to store our integer number in t0 temporarily
    li t2, 10 # To convert to base 10
    
    # Lets check if number is negative
    lbu t1, 0(a0) # Check the first caracter
    li t3, 45 # Equals to '-', aka minus sign
    beq t1, t3, negative
    j positive # If it reachs this line, than logically its a positive number

    positive:
        lbu t1, 0(a0) # Load first caracter
        beqz t1, end_positive # We reached \n caracter 
        mul t0, t0, t2 
        addi t1, t1, -48 # From ASCII to integer
        add t0, t0, t1
        addi a0, a0, 1 # To the next caracter
        j positive
    end_positive:
        mv a0, t0
        ret

    negative:
        lbu t1, 1(a0) # Start with second caracter
        beqz t1, negative_end # We reached \n caracter
        mul t0, t0, t2
        addi t1, t1, -48 # From ASCII to integer
        add t0, t0, t1
        addi a0, a0, 1
        j negative
    negative_end:
        li t1, -1
        mul t0, t0, t1 # Convert the number to the equivalent negative integer
        mv a0, t0
        ret


.globl itoa
itoa:
/*a0: index value
a1: adress of output string
a2: numeric base*/
    mv a6, a1 # We store a1 original adress because its going to change
    li t0, -1
    beq t0, a0, negative_format
    li t0, 0
    beq t0, a0, zero_format
    li t0, 10
    li t1, 1 # If positive or 0, output will have at least 1 digit
    beq t0, a2, decimal
    li t0, 16
    beq t0, a2, hexadecimal
    la a1, output # Will temporarily store output string on register a4

    zero_format:
        li t0, '0'
        sb t0, 0(a1)
        addi a1, a1, 1
        j adjust

    negative_format:
        li t0, '-'
        sb t0, 0(a1)
        addi a1, a1, 1
        li t0, '1'
        sb t0, 0(a1)
        addi a1, a1, 1 # Move to next caracter
        j adjust

    decimal:
        beqz a0, decimal_over
        remu t0, a0, a2 # t0 <- a0%10
        addi t0, t0, 48 # Int -> ASCII
        addi sp, sp, -4
        sw t0, 0(sp)
        div a0, a0, a2 # a0 <- a0/10
        addi t1, t1, 1 # We count one more digit
        j decimal
    decimal_over:
        beqz t1, adjust
        lw t0, 0(sp)
        addi sp, sp, 4
        sw t0, 0(a1)
        addi a1, a1, 1
        addi t1, t1, -1 # This loop will continue until t1 is zero
        j decimal_over
    
    hexadecimal:
        beqz a0, hexadecimal_over
        remu t0, a0, a2 # t0 <- a0%16
        li t2, 10
        blt t0, t2, number
        letter:
            addi t0, t0, 55
            j stack
        number:
            addi t0, t0, 48
            j stack
        stack:     
        addi sp, sp, -4
        sw t0, 0(sp)
        div a0, a0, a2 # a0 <- a0/16
        addi t1, t1, 1
        j hexadecimal
        hexadecimal_over:
            beqz t1, adjust
            lw t0, 0(sp)
            addi sp, sp, 4
            sw t0, 0(a1)
            addi a1, a1, 1
            addi t1, t1, -1
            j hexadecimal_over
    
    adjust:
        li t0, 0
        sb t0, 0(a1)
        mv a0, a6 # We get a1 original adress again
        ret


.globl exit
exit:
    li a7, 10 # Syscall for exit
    ecall
