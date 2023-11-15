.text
.align 4


set_engine_and_steering:
    la s0, BASE
    addi s0, s0, 32 # base+0x20
    sb a1, 0(s0)
    addi s0, s0, 1 # base + 0x21
    sb a0, 0(s0)
    ret

int_handler:
  ###### Syscall and Interrupts handler ######
  csrrw sp, mscratch, sp # Changes sp to mscratch
  addi sp, sp, -12
  sw a0, 0(sp)
  sw a1, 4(sp)
  sw a7, 8(sp)

  li t0, 10
  li t1, 11
  li t2, 15
  beq a7, t0, syscall_set_engine_and_steering

  syscall_set_engine_and_steering:
    jal set_engine_and_steering

  lw a7, 8(sp)
  lw a1, 4(sp)
  lw a0, 0(sp)
  addi sp, sp, 12
  
  csrrw sp, mscratch, sp

  csrr t0, mepc  # load return address (address of 
                 # the instruction that invoked the syscall)
  addi t0, t0, 4 # adds 4 to the return address (to return after ecall) 
  csrw mepc, t0  # stores the return address back on mepc
  mret           # Recover remaining context (pc <- mepc)
  

.globl _start
_start:

  la a0, int_handler  # Load the address of the routine that will handle interrupts
  csrw mtvec, a0      # (and syscalls) on the register MTVEC to set
                      # the interrupt array.
  la a0, USER_stack_end
  csrw mscratch, a0

  # Allow external interruptions
  csrr t1, mie # Set bit 11 (MEIE)
  li t2, 0x800
  or t1, t1, t2
  csrw mie, t1

  # Allow global interruptions
  csrr t1, mstatus # Set bit 3 (MIE)
  ori t1, t1, 0x8
  csrw mstatus, t1

  # Change to user mode
  csrr t1, mstatus # Update the mstatus.MPP
  li t2, ~0x1800 # field (bits 11 and 12)
  and t1, t1, t2 # with value 00 (U-mode)
  csrw mstatus, t1
  la t0, user_main # Loads the user software
  csrw mepc, t0 # entry point into mepc
  mret # PC <= MEPC; mode <= MPP;

  jal user_main

# Write here the code to change to user mode and call the function 
# user_main (defined in another file). Remember to initialize
# the user stack so that your program can use it.

.globl control_logic
control_logic:
  li a0, 1 # Make car go forward
  li a1, -15 # Make car go to left
  li a7, 10
  ecall

  infinite_loop:
    j infinite_loop


.bss
.align 4
USER_stack: .skip 1024
USER_stack_end:
.set BASE, 0xFFFF0100