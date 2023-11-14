.data
.set BASE_WRITE, 0xFFFF0100 
.set BYTE_WRITE, 0xFFFF0101
.set BASE_READ, 0xFFFF0102
.set BYTE_READ, 0xFFFF0103
.bss
input: .skip 100
output: .skip 100

/*
op 1: read a string and write it back to serial port
op 2: read a string and write it back to serial port reversed
op 3: read a number in decimal represation and write it back in hexadecimal represation
op 4: read numeric expression and return decimal result
*/

.text
.globl _start
_start:
    jal main 
    jal exit

main:
    jal read # Register a0 is returned with beginning adress of input string
    jal check_operation
    ret

read:
    la a1, input # We load adress of input string in register a1
    mv s0, a1 # We save adress of input string in s0 to use it later

    read_loop:
        li a0, BASE_READ # Load adress of base+0x02
        li t0, 1
        sb t0, 0(a0) # 1 triggers serial port to begin reading

        stop_read:
            lb t0, 0(a0)
            beq t0, x0, continue_read # We will only story out read byte when register is set to 0
            j stop_read
        
        continue_read:
            li a0, BYTE_READ # Load adress of base+0x03 which contains our read byte
            lb t0, 0(a0)
            beqz t0, read_over # If null is read, we stop
            sb t0, 0(a1)
            addi a1, a1, 1 # Move to the next position of our buffer
            j read_loop

    read_over:
        li t0, 0
        sb t0, 0(a1) # We store null caracter at the end of input string
        mv a0, s0 # We load adress of input string to a0 to return it
        ret 

check_operation:
    lb t0, 0(a0) # We load first byte of input in register a0

    li t1, '1'
    beq t0, t1, operation_1

    li t1, '2'
    beq t0, t1, operation_2

    li t1, '3'
    beq t0, t1, operation_3

    li t1, '4'
    beq t0, t1, operation_4


operation_1:
    addi a0, a0, 2 # We move to position 2 of input string 

    addi sp, sp, -4
    sw ra, 0(sp)
    jal write
    lw ra, 0(sp)
    addi sp, sp, 4
    ret


operation_2:
    addi a0, a0, 2

    addi sp, sp, -4
    sw ra, 0(sp)
    jal reverse_operation
    lw ra, 0(sp)
    addi sp, sp, 4

    addi sp, sp, -4
    sw ra, 0(sp)
    jal write
    lw ra, 0(sp)
    addi sp, sp, 4

    ret


operation_3:
    addi a0, a0, 2

    addi sp, sp, -4
    sw ra, 0(sp)
    jal conversion_to_hexadecimal
    lw ra, 0(sp)
    addi sp, sp, 4

    addi sp, sp, -4
    sw ra, 0(sp)
    jal write
    lw ra, 0(sp)
    addi sp, sp, 4

    ret


operation_4:
    addi a0, a0, 2
    
    addi sp, sp, -4
    sw ra, 0(sp)
    jal algebric_expression
    lw ra, 0(sp)
    addi sp, sp, 4
    
    addi sp, sp, -4
    sw ra, 0(sp)
    jal convert_to_decimal
    lw ra, 0(sp)
    addi sp, sp, 4

    addi sp, sp, -4
    sw ra, 0(sp)
    jal write
    lw ra, 0(sp)
    addi sp, sp, 4

    ret


conversion_to_hexadecimal:
    li t0, 0 # To temporarily store our decimal number
    li t2, 10 # Base 10 conversion

    # To check if our number is negative
    lbu t1, 0(a0) 
    li t3, 45 # ASCII for minus sign -
    beq t1, t3, negative_number 
    j positive_number

    negative_number:
        lbu t1, 1(a0)
        beq t1, t2, negative_end # We reached newline caracter
        mul t0, t0, t2
        addi t1, t1, -48 # From ASCII to integer
        add t0, t0, t1
        addi a0, a0, 1 # Move to next caracter
        j negative_number

    negative_end:
        li t1, -1
        mul a0, t0, t1 # Convert number to its negative equivalent and store it in register a0
        j convert_to_hexadecimal

    positive_number:
        lbu t1, 0(a0)
        beq t1, t2, positive_end
        mul t0, t0, t2
        addi t1, t1, -48 # From ASCII to integer
        add t0, t0, t1
        add a0, a0, 1
        j positive_number

    positive_end:
        li t1, 1
        mul a0, t0, t1 # Store our number in register a0

    convert_to_hexadecimal:
        # Register a0 has our decimal number that will be converted
        la a1, output # We load begin adress of our output in register a1
        li a2, 16 # To make base 16 conversion
        mv a3, a1 # We will keep begin adress of our output buffer

        li t0, 0
        li t1, 0 # To count number of digits
        blt a0, t0, negative_hexadecimal
        j hexadecimal

        negative_hexadecimal:

        hexadecimal:
            beqz a0, hexadecimal_over
            rem t0, a0, a2 # t0 <- a0%16
            li t2, 10
            blt t0, t2, number

            letter:
                addi t0, t0, 55
                j hexadecimal_stack

            number:
                addi t0, t0, 48
                j hexadecimal_stack

            hexadecimal_stack:
                addi sp, sp, -4
                sw t0, 0(sp)
                div a0, a0, a2 # a0 <- a0/16
                addi t1, t1, 1
                j hexadecimal

        hexadecimal_over:
            beqz t1, adjust_hexadecimal
            lw t0, 0(sp)
            addi sp, sp, 4
            sw t0, 0(a1)
            addi a1, a1, 1
            addi t1, t1, -1
            j hexadecimal_over

        adjust_hexadecimal:
            li t0, 0
            sb t0, 0(a1)
            mv a1, a3 # Recover begin adress of output buffer
            mv a0, a1 # Return begin adress in register a0
            ret


algebric_expression:
        first_number:
            li t0, 0 # Store our number
            li t2, 10 # Decimal base conversion
            li t3, 45 # ASCII for minus sign -
            lbu t4, 0(a0)
            beq t4, t3, negative_first_number
            li t3, ' '
            li s0, 1 # Number is positive
            j loop_first_number

            negative_first_number:
                addi a0, a0, 1 # We skip the minus sign
                li s0, -1 # To convert number to its negative equivalent
                li t3, ' '

            loop_first_number:
                lb t1, 0(a0)
                beq t1, t3, done_first_number
                mul t0, t0, t2 
                addi t1, t1, -48 # From ASCII to integer
                add t0, t0, t1
                addi a0, a0, 1 # To the next caracter
                j loop_first_number
        
            done_first_number:
                addi a0, a0, 1 # We leave the space behind and will next check op
                mul s0, s0, t0 # We will get the right sign and store it in s0
                j verify_operation

    # Now we will procced to verify which algebric expression we will compute.
    verify_operation:
        lb t0, 0(a0)
        addi a0, a0, 2 # To skip next space and get at begin adress of second number

        li t1, 43 # ASCII for +
        beq t1, t0, sum

        li t1, 45 # ASCII for -
        beq t0, t1, minus

        li t1, 47 # ASCII for /
        beq t0, t1, division

        li t1, 42 # ASCII for *
        beq t0, t1, multiplication

        sum: 
            li s1, 43
            j second_number

        minus:
            li s1, 45
            j second_number

        division:
            li s1, 47
            j second_number

        multiplication: 
            li s1, 42

            
    second_number:
        li t0, 0 # Store our number
        li t2, 10 # Decimal base conversion
        li t3, 45 # ASCII for minus sign -
        lbu t4, 0(a0)
        beq t4, t3, negative_second_number
        li s2, 1 # Number is positive
        j loop_second_number

        negative_second_number:
            addi a0, a0, 1 # We skip the minus sign
            li s2, -1 # To convert number to its negative equivalent

        loop_second_number:
            lb t1, 0(a0)
            beq t1, t2, done_second_number
            mul t0, t0, t2 
            addi t1, t1, -48 # From ASCII to integer
            add t0, t0, t1
            addi a0, a0, 1 # To the next caracter
            j loop_second_number
    
        done_second_number:
            addi a0, a0, 1 # We leave the space behind and will next check op
            mul s2, s2, t0 # We will get the right sign and store it in s0
            j compute_expression


    compute_expression:
        li t0, '+' 
        beq t0, s1, sum_operation

        li t0, '-' 
        beq t0, s1, minus_operation

        li t0, '/' 
        beq t0, s1, division_operation

        li t0, '*' 
        beq t0, s1, multiplication_operation

        sum_operation: 
            add a0, s0, s2
            ret
        
        minus_operation:
            sub a0, s0, s2
            ret

        division_operation:
            div a0, s0, s2
            ret
        
        multiplication_operation:
            mul a0, s0, s2
            ret


convert_to_decimal:
    # Register a0 has our decimal number
    # Register a1 has the begin adress of output buffer
    la a1, output
    mv a2, a1 # Store begin adress of output buffer in register a2
    li t0, 0 # To check if it is 0 or negative
    li t1, 0 # To count number of digits
    li t2, 10 # To convert to decimal base

    beq t0, a0, convert_to_zero
    blt a0, t0, convert_to_negative_number 

    j convert_to_standard_number

    convert_to_zero:
        li t0, '0'
        sb t0, 0(a1)
        addi a1, a1, 1
        j adjust_decimal


    convert_to_negative_number:
        li t0, '-'
        sb t0, 0(a1)
        li t0, -1
        mul a0, a0, t0 # Get positive equivalent of number
        addi a1, a1, 1 # Move to next position of our buffer
        j convert_to_standard_number


    convert_to_standard_number:
        beqz a0, conversion_over
        remu t0, a0, t2 # t0 <- a0%10
        addi t0, t0, 48 # From int to ASCII
        addi sp, sp, -4
        sw t0, 0(sp) # Store digit in our stack
        div a0, a0, t2 # a0 <- a0/10
        addi t1, t1, 1 # Count one more digit
        j convert_to_standard_number

        conversion_over:
            beqz t1, adjust_decimal
            lw t0, 0(sp)
            addi sp, sp, 4
            sw t0, 0(a1)
            addi a1, a1, 1 # Move to next position of buffer
            addi t1, t1, -1 # Loop will continue until we have stored all digits
            j conversion_over


    adjust_decimal:
        li t0, 0
        sb t0, 0(a1) # Store null caracter at end of buffer
        mv a1, a2 # Recover begin adress of our buffer
        mv a0, a1 # Store begin adress in register a0 
        ret


reverse_operation:
    # Register a0 has the begin adress of the string we want to reverse
    la a1, output # Register a1 will receive adress of output
    mv a2, a1 # We will preserve begin adress of output to use it later
    
    li t0, 0
    addi sp, sp, -4
    sw t0, 0(sp) # We push 0 to stack to use it as a null caracter

    stack_reverse:
        lb t0, 0(a0)
        li t1, 10 # Newline caracter
        beq t0, t1, reverse # We reach end of string and will procced to reverse it
        addi a0, a0, 1 # Move to next position of input buffer
        addi sp, sp, -4
        sw t0, 0(sp)
        j stack_reverse 


    reverse:
        lw t0, 0(sp)
        addi sp, sp, 4
        beqz t0, reverse_over # We reached null caracter and will stop
        sb t0, 0(a1)
        addi a1, a1, 1 # Move to next position of output buffer
        j reverse


    reverse_over:
        li t0, 10
        sb t0, 0(a1) # We store newline caracter 
        li t0, 0
        sb t0, 1(a1) # We store null caracter at the end of output string
        mv a0, a2 # We load begin adress of output string to a0 to return it
        ret    


write:
    # Resgister a0 has begin adress to our input buffer
    li a1, BYTE_WRITE # Store the byte we will read in register a1
    lb t0, 0(a0) 

    sb t0, 0(a1)

    li a1, BASE_WRITE
    li t0, 1
    sb t0, 0(a1)

    stop_write:
        lb t0, 0(a1)
        beq t0, x0, continue_write
        j stop_write

    continue_write:
        addi a0, a0, 1
        lb t0, 0(a0)
        beqz t0, write_over
        j write


    write_over:
        li a1, BYTE_WRITE
        li t0, 10 # Newline caracter
        sb t0, 0(a1)

        li a1, BASE_WRITE
        li t0, 1
        sb t0, 0(a1)

        ret

exit:
    li a7, 10
    ecall