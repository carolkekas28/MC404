/*
- Lemos a string e a armazenamos no seu registrador
- Processamos de 1 em 1 numero (com seus 4 caracteres)
- Convertemos o numero em inteiro e armazenamos em a0
- Utilizamos o numero a0 para calcular a raiz com o metodo dito
e armazenamos o resultado em a0
- Guardamos o resultado na posicao equivalente da string de saida
- Passamos para o proximo numero
- No fim, formatamos a string adicionando espacos e \n
*/

.bss
input: .skip 20
output: .skip 20

/*
    s0: guardo o endereco do input
    s1: guardo o endereco do output
    a0-a3: guardo os numeros e eventualmente suas raizes
    t0-t3: armazeno variaveis auxiliares
*/

.text
.globl _start


_start:
    jal main
    jal exit

main:
    jal read
    la s0, input
    la s1, output
    # Primeiro numero
    jal char_para_int
    jal metodo_babilonico
    jal primeiro
    # Segundo numero
    addi s0, s0, 5
    jal char_para_int
    jal metodo_babilonico
    jal segundo
    # Terceiro numero
    addi s0, s0, 5
    jal char_para_int
    jal metodo_babilonico
    jal terceiro
    # Quarto numero
    addi s0, s0, 5
    jal char_para_int
    jal metodo_babilonico
    jal quarto
    # Adicionando espacos e \n
    jal ajusta
    jal write
    jalr x0, ra, 0


char_para_int:
    # Padrao
    lb t0, 0(s0)
    addi t0, t0, -48 # Converte de ASCII para inteiro
    li t1, 1000 
    mul t0, t0, t1 # Multiplicamos pela respectiva unidade
    addi a0, t0, 0 # Adicionamos ao registrador

    lb t0, 1(s0)
    addi t0, t0, -48
    li t1, 100
    mul t0, t0, t1
    add a0, a0, t0

    lb t0, 2(s0)
    addi t0, t0, -48
    li t1, 10
    mul t0, t0, t1
    add a0, a0, t0

    lb t0, 3(s0)
    addi t0, t0, -48
    add a0, a0, t0

    jalr x0, ra, 0

metodo_babilonico:
    srai t0, a0, 1
    
    divu t1, a0, t0
    add t2, t1, t0
    srai t0, t2, 1

    divu t1, a0, t0
    add t2, t1, t0
    srai t0, t2, 1

    divu t1, a0, t0
    add t2, t1, t0
    srai t0, t2, 1

    divu t1, a0, t0
    add t2, t1, t0
    srai t0, t2, 1

    divu t1, a0, t0
    add t2, t1, t0
    srai t0, t2, 1

    divu t1, a0, t0
    add t2, t1, t0
    srai t0, t2, 1

    divu t1, a0, t0
    add t2, t1, t0
    srai t0, t2, 1

    divu t1, a0, t0
    add t2, t1, t0
    srai t0, t2, 1

    divu t1, a0, t0
    add t2, t1, t0
    srai t0, t2, 1

    divu t1, a0, t0
    add t2, t1, t0
    srai t0, t2, 1

    divu t1, a0, t0
    add t2, t1, t0
    srai t0, t2, 1

    divu t1, a0, t0
    add t2, t1, t0
    srai t0, t2, 1

    mv a0, t0

    jalr x0, ra, 0

primeiro:
    li t0, 10 # Para calcularmos o digito que eh o resto da divisao
    rem t1, a0, t0 # Pegamos o resto e armazenamos em t1
    addi t1, t1, 48 # Convertemos de inteiro para ASCII
    sb t1, 3(s1) # Armazenamos na posicao correta
    div a0, a0, t0 # Dividimos por 10 para pegar o proximo digito

    rem t1, a0, t0
    addi t1, t1, 48
    sb t1, 2(s1)
    div a0, a0, t0

    rem t1, a0, t0
    addi t1, t1, 48
    sb t1, 1(s1)
    div a0, a0, t0

    rem t1, a0, t0
    addi t1, t1, 48
    sb t1, 0(s1)

    jalr x0, ra, 0

segundo:
    li t0, 10
    rem t1, a0, t0
    addi t1, t1, 48
    sb t1, 8(s1)
    div a0, a0, t0

    rem t1, a0, t0
    addi t1, t1, 48
    sb t1, 7(s1)
    div a0, a0, t0

    rem t1, a0, t0
    addi t1, t1, 48
    sb t1, 6(s1)
    div a0, a0, t0

    rem t1, a0, t0
    addi t1, t1, 48
    sb t1, 5(s1)

    jalr x0, ra, 0

terceiro:
    li t0, 10
    rem t1, a0, t0
    addi t1, t1, 48
    sb t1, 13(s1)
    div a0, a0, t0

    rem t1, a0, t0
    addi t1, t1, 48
    sb t1, 12(s1)
    div a0, a0, t0

    rem t1, a0, t0
    addi t1, t1, 48
    sb t1, 11(s1)
    div a0, a0, t0

    rem t1, a0, t0
    addi t1, t1, 48
    sb t1, 10(s1)

    jalr x0, ra, 0

quarto:
    li t0, 10
    rem t1, a0, t0
    addi t1, t1, 48
    sb t1, 18(s1)
    div a0, a0, t0

    rem t1, a0, t0
    addi t1, t1, 48
    sb t1, 17(s1)
    div a0, a0, t0

    rem t1, a0, t0
    addi t1, t1, 48
    sb t1, 16(s1)
    div a0, a0, t0

    rem t1, a0, t0
    addi t1, t1, 48
    sb t1, 15(s1)

    jalr x0, ra, 0

ajusta:
    li t0, '\n'
    sb t0, 19(s1)
    li t0, ' '
    sb t0, 4(s1)
    sb t0, 9(s1)
    sb t0, 14(s1)
    
    jalr x0, ra, 0

read:
    li a0, 0  # file descriptor = 0 (stdin)
    la a1, input #  buffer to write the data
    li a2, 20  # size (reads only 1 byte)
    li a7, 63 # syscall read (63)
    ecall
    
    jalr x0, ra, 0

write:
    li a0, 1            # file descriptor = 1 (stdout)
    la a1, output       # buffer
    li a2, 20           # size
    li a7, 64           # syscall write (64)
    ecall
    
    jalr x0, ra, 0

exit:
    li a0, 10
    ecall