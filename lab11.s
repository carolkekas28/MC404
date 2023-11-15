.data
.bss
.text 
.set BASE, 0xFFFF0100
/*O que preciso fazer:
- Ligar o GPS
- Andar com o carro ate o ponto de chegada
- Desligar o carro
- Sair do programa*/
.globl _start 

_start:
    jal main
    jal exit

main:
    jal start_gps
    ret

start_gps:
    li a0, BASE # We load adress of base in register a0
    li t0, 1 # 1 to trigger the GPS device to start working
    sb t0, 0(a0)
    /*check_base1:
        lb t0, 0(a0)
        li t1, 0
        bne t0, t1, check_base1 # It wont advance as long as the reading isnt finished
    */
move_car:
    # We will check the steering wheel direction
    addi a0, a0, 32 # base+0x20
    li t0, -14
    sb t0, 0(a0) # Negative values will make the car turn to the left
    addi a0, a0, 1 # base+0x21
    li t0, 1 # Engine direction is set to forward
    sb t0, 0(a0)

    li a0, 0
    loop_move_car:
        li t0, 1
        beq a0, t0, end_move_car

        li a0, BASE
        li t0, 1
        sb t0, 0(a0)
       /* check_base2:
            lb t0, 0(a0)
            li t1, 0
            bne t0, t1, check_base2
*/
        addi a0, a0, 32 # base+0x20
        li t0, -14
        sb t0, 0(a0)
        addi a0, a0, 1
        li t0, 1
        sb t0, 0(a0)
        
        addi sp, sp, -4
        sw ra, 0(sp)
        jal verify_destiny
        lw ra, 0(sp)
        addi sp, sp, 4

        j loop_move_car

    end_move_car:
        li a0, BASE
        addi a0, a0, 34
        li t0, 1
        sb t0, 0(a0)
        ret

verify_destiny:
    li a0, BASE
    li t0, 1
    sb t0, 0(a0)
    /*check_base3:
        lb t0, 0(a0)
        li t1, 0
        bne t0, t1, check_base3    
    */
    # Setting the coordinates of the entrance to the Test Track
    li s1, 73
    li a2, 1
    li a3, -19

    # We advance to adress a0 + 16 to start reading current coordinates of the car
    addi a0, a0, 16 # base+0x10
    lw t1, 0(a0) # Load value of x0
    addi a0, a0, 4 # base+0x14
    lw t2, 0(a0) # Load value of y0
    addi a0, a0, 4 # base+0x18
    lw t3, 0(a0) # Load value of z0

    # We will procced to check if we have reached the wished point of arrival
    sub t1, s1, t1 # t1 <- x - x0
    sub t2, s2, t2 # t2 <- y - y0
    sub t3, s3, t3 # t3 <- z - z0

    mul t1, t1, t1 # t1 <- (x - x0)ˆ2
    mul t2, t2, t2 # t2 <- (y - y0)ˆ2
    mul t3, t3, t3 # t3 <- (z - z0)ˆ2

    add s0, t1, t2
    add s0, s0, t3 # s0 <- (x - x0)ˆ2 + (y - y0)ˆ2 + (z - z0)ˆ2

    # Remember that the car should be inside a radius of 15 meters to reach the entrance point
    li t0, 225 # t0 <- 15ˆ2
    bge t0, s0, entrance_reached # If t0 >= s0, we have reached entrance point
    li a0, 0
    ret

entrance_reached:
    li a0, BASE
    addi a0, a0, 33
    li t0, 0
    sb t0, 0(a0)
    ret 

exit:
    li a7, 10
    ecall
