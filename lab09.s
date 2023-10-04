.bss 
output: .skip 4 # String que armazenaremos o resultado encontrado
input: .skip 6

.text
.globl _start

_start:
    jal main
    jal exit


main:
    jal read # Lemos a entrada do usuario
    la s0, input # Armazenamos a string no registrador s0
    la s1, output # String para imprimir o resultado
    la a0, head_node # Carregamos o no cabeca da lista ligada em a0
    jal char_para_int # Convertemos a string recebida para inteiro, armazenado em s0
    jal percorre_lista # Percorremos a lista para verificar se a soma esta em algum no
    jal int_para_char # Convertemos o indice para string
    jal write # Imprimimos o resultado
    ret


int_para_char:
    # Verificamos se nao foi encontrada a soma nos nos da lista
    li t0, -1
    beq a4, t0, formata_negativo
    # Verificamos se a soma foi encontrada no primeiro no (indice 0)
    beqz a4, formata_zero
    # Se nao for nenhum dos casos, formatamos um positivo.
    j formata_positivo

    formata_zero:
        li t0, '0'
        sb t0, 0(s1)
        li t0, '\n'
        sb t0, 1(s1)
        ret

    formata_negativo:
        li t0, '-' # Carregamos o caracter de menos
        sb t0, 0(s1)
        li t0, '1'
        sb t0, 1(s1)
        li t0, '\n'
        sb t0, 2(s1)
        ret
    
    /* O numero maximo de nos eh 200, entao sabemos que o indice maximo possivel tem
    3 digitos. Vamos trabalhar com isso*/
    formata_positivo:
        addi sp, sp, -4
        sw ra, 0(sp) # Preservamos o valor de ra
        jal conta_digitos # Guardamos em a0 a quantidade de digitos do indice
        lw ra, 0(sp)
        addi sp, sp, 4

        li t0, 3
        beq t0, a0, tres_digitos
        li t0, 2
        beq t0, a0, dois_digitos
        li t0, 1
        beq t0, a0, um_digito

        um_digito:
            addi a4, a4, 48 # De inteiro para ASCII
            sb a4, 0(s1) 
            li t0, 10
            sb t0, 1(s1)
            ret

        dois_digitos:
            li t1, 10
            rem t0, a4, t1 # t0 <- a2%10
            addi t0, t0, 48
            div a4, a4, t1
            sb t0, 1(s1) 

            rem t0, a4, t1 
            addi t0, t0, 48
            sb t0, 0(s1)

            li t0, 10
            sb t0, 2(s1)
            ret

        tres_digitos:
            li t1, 10
            rem t0, a4, t1 
            addi t0, t0, 48
            div a4, a4, t1 # s2 <- s2/10
            sb t0, 2(s1)

            rem t0, a4, t1
            addi t0, t0, 48
            div a4, a4, t1 # s2 <- s2/100
            sb t0, 1(s1)

            rem t0, a4, t1
            addi t0, t0, 48
            sb t0, 0(s1)

            li t0, 10
            sb t0, 3(s1)
            ret


conta_digitos:
    li a0, 1
    li t0, 10
    mv a1, a4 # Armazenamos s2 em a1 temporariamente

    laco:
        remu t1, a1, t0 # t1 <- a1%10
        divu a1, a1, t0 # t1 <- a1/10
        bnez a1, adiciona # t1 != 0, vamos contabilizar mais um digito
        ret
        adiciona:
            addi a0, a0, 1 # Adicionamos mais um digito em a0
            j laco


percorre_lista:
    li t0, 0 # Correspondente ao indice inicial da lista
    
    loop:
        lw a1, 0(a0) # Carregamos o primeiro numero em a1
        lw a2, 4(a0) # Carregamos o segundo numero em a2
        add a3, a1, a2 # Somamos os dois e guardamos em a3
        beq s0, a3, achou # Se a soma for igual, achamos e vamos registrar o indice
        beqz a2, nao_achou # Caso tenhamos chegado ao final da lista
        lw a0, 8(a0) # Vamos para o proximo no
        addi t0, t0, 1 # Atualizamos o indice para o proximo
        j loop
    
    nao_achou:
        li a4, -1
        ret
    
    achou:
        mv a4, t0 # Guardamos o indice no registrador 4
        ret


char_para_int:
    li t0, 0 # Inicializamos o resultado como 0
    li t2, 10 # Para convertermos para base 10
    # Vamos checar se o numero eh negativo
    lbu t1, 0(s0) # Carregamos o primeiro caracter do input para checar
    li t3, 45 # Valor correspondente a '-'
    beq t1, t3, numero_negativo # Se o primeiro caracter eh '-', o numero eh negativo
    j numero_positivo

    numero_negativo:
        lbu t1, 1(s0) # Carregamos o segundo caracter
        li t3, 10 # Carregamos o valor de /n
        beq t1, t3, 1f # Fim da string
        mul t0, t0, t2 # Multiplicamos o resultado atual por t0
        addi t1, t1, -48 # Passamos de ASCII para inteiro
        add t0, t0, t1 # Adicionamos o digito ao resultado
        addi s0, s0, 1 # Movemos pro proximo caracter
        j numero_negativo
    1:
        li t1, -1 # Carregamos -1
        mul t0, t0, t1 # Tornamos o numero em negativo
        mv s0, t0 # Armazenamos o resultado em s0 de novo, agora como inteiro
        ret
    
    /*O que eh feito aqui eh similar ao label do numero negativo, entao
    nao irei explicar detalhadamente o que eh feito (visto que eh pratica-
    mente a mesma coisa.*/
    numero_positivo:
        lbu t1, 0(s0) # Carregamos o primeiro caracter
        li t3, 10
        beq t1, t3, 2f 
        mul t0, t0, t2 
        addi t1, t1, -48
        add t0, t0, t1
        addi s0, s0, 1 # Vamos para o proximo caracter
        j numero_positivo
    2:
        mv s0, t0 
        ret


read:
    li a0, 0  # file descriptor = 0 (stdin)
    la a1, input #  buffer to write the data
    li a2, 6  # size (reads only 1 byte)
    li a7, 63 # syscall read (63)
    ecall
    ret


write:
    li a0, 1            # file descriptor = 1 (stdout)
    la a1, output       # buffer
    li a2, 4           # size
    li a7, 64           # syscall write (64)
    ecall
    ret


exit:
    li a7, 10
    ecall