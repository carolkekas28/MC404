.bss
primeiro_input: .skip 5
segundo_input: .skip 10
primeiro_output: .skip 10
segundo_output: .skip 10
erro: .skip 5
.text
.globl _start

_start:
    jal main
    jal exit

main:
    jal read1
    jal read2
    la s0, primeiro_input
    la s1, primeiro_output
    la s2, segundo_input
    la s3, segundo_output
    la s4, erro
    jal codigo_hamming
    jal formata_output
    jal decodifica
    jal write1
    jal write2
    jal verifica_erro
    jal write3
    ret

decodifica:
# Armazenamos os elementos referentes a d1, d2, d3 e d4
    lb t0, 2(s2)
    sb t0, 0(s3)

    lb t0, 4(s2)
    sb t0, 1(s3)

    lb t0, 5(s2)
    sb t0, 2(s3)

    lb t0, 6(s2)
    sb t0, 3(s3)

    li t0, '\n' 
    sb t0, 4(s3)

    ret

codigo_hamming: 
# Vou guardar d1, d2, d3 e d4 nos registradores temporarios t0 a t3
    lb t0, 0(s0) # Aqui temos d1
    add t0, t0, -48 # ASCII -> int

    lb t1, 1(s0) # Aqui temos d2
    add t1, t1, -48 # ASCII -> int

    lb t2, 2(s0) # Aqui temos d3
    add t2, t2, -48 # ASCII -> int

    lb t3, 3(s0) # Aqui temos d4
    add t3, t3, -48 # ASCII -> int
# Aqui vou verificar a paridade de p1, p2 e p3
    xor a0, t0, t1
    xor a1, a0, t3 # p1 = XOR(d1d2d4)
    addi a1, a1, 48 # int  -> ASCII

    xor a0, t0, t2
    xor a2, a0, t3 # p2 = XOR(d1d3d4)
    addi a2, a2, 48

    xor a0, t1, t2
    xor a3, a0, t3 # p3 = XOR(d2d3d4)
    addi a3, a3, 48

    ret

formata_output:
    sb a1, 0(s1)
    sb a2, 1(s1)
    sb a3, 3(s1)

    lb t0, 0(s0)
    sb t0, 2(s1)

    lb t0, 1(s0)
    sb t0, 4(s1)

    lb t0, 2(s0)
    sb t0, 5(s1)

    lb t0, 3(s0)
    sb t0, 6(s1)

    li t0, '\n'
    sb t0, 7(s1)
    ret

verifica_erro:
    # Garantimos que o valor de ra nao sera alterado
    addi sp, sp, -4
    sw ra, 0(sp)

    mv s0, s3
    jal codigo_hamming
    la s1, segundo_input

    lb t0, 0(s1)
    bne t0, a1, erro_detectado

    lb t0, 1(s1)
    bne t0, a2, erro_detectado

    lb t0, 3(s1)
    bne t0, a3, erro_detectado

    j sem_erro

    erro_detectado:
    # Novamente, tomamos cuidado com ra 
        lw ra, 0(sp)
        addi sp, sp, 4
        li t0, '1'
        sb t0, 0(s4)
        li t0, '\n'
        sb t0, 1(s4)
        ret
    
    sem_erro:
        lw ra, 0(sp)
        addi sp, sp, 4
        li t0, '0'
        sb t0, 0(s4)
        li t0, '\n'
        sb t0, 1(s4)
        ret

read1:
    li a0, 0  # file descriptor = 0 (stdin)
    la a1, primeiro_input #  buffer to write the data
    li a2, 5  # size (reads only 1 byte)
    li a7, 63 # syscall read (63)
    ecall
    ret

read2:
    li a0, 0  # file descriptor = 0 (stdin)
    la a1, segundo_input #  buffer to write the data
    li a2, 10  # size (reads only 1 byte)
    li a7, 63 # syscall read (63)
    ecall
    ret

write1:
    li a0, 1            # file descriptor = 1 (stdout)
    la a1, primeiro_output  # buffer
    li a2, 10            # size
    li a7, 64           # syscall write (64)
    ecall
    ret

write2:
    li a0, 1            # file descriptor = 1 (stdout)
    la a1, segundo_output # buffer
    li a2, 10            # size
    li a7, 64           # syscall write (64)
    ecall
    ret

write3:
    li a0, 1            # file descriptor = 1 (stdout)
    la a1, erro         # buffer
    li a2, 5            # size
    li a7, 64           # syscall write (64)
    ecall
    ret

exit:
    li a0, 10
    ecall