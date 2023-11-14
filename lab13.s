/*
GPT: 
-> base+0x00: byte - storing 1 triggers GPT device to start reading current system
time. Register is set to 0 when reading is completed
-> base+0x04: world - stores the time (in miliseconds) at the moment of the last
reading by the GPT
-> base+0x08: world - storing v > 0 programs the GPT to generate an external 
interruption after v miliseconds. It also sets this register to 0 after v 
miliseconds.
MDI Synthesizer:
-> base+0x00: Storing ch triggers the synthesizer to start playing a MIDI note
-> base+0x02: Instrument ID
-> base+0x04: Note
-> base+0x05: Note velocity
-> base+0x06: Note duration
*/
.text
.globl _start
.globl play_note
.globl _system_time    


GPT_interruption:
    # We are going to program GPT to interrupt every 100 ms, as suggested
    la a0, BASE_GPT # We load begin adress of GPT base in register a0
    li t0, 1 # This will trigger GPT device to read current system time
    sb t0, 0(a0) # Trigger activation

    stop_GPT_interruption:
        lb t0, 0(a0)
        beq t0, x0, procced_GPT_reading
        j stop_GPT_interruption

    procced_GPT_reading:
        la a1, _system_time # Store adress of our global time counter in register a1
        lw t0, 4(a0) # Move to base+0x04, where time is stored, and store this value in t0
        lw t1, 0(a1) # Load system time in register t1
        sw t0, 0(a1) 

        li t0, 200
        sw t0, 8(a0) # To generate an external interruption after 100 miliseconds

        ret


play_note:
    # a0: channel, a1: instrument ID, a2: musical note, a3: note velocity, a4: note duration
    la s0, BASE_MIDI # We load begin adress of MIDI Synthesizer in register s0
    sb a0, 0(s0)
    sh a1, 2(s0)
    sb a2, 4(s0)
    sb a3, 5(s0)
    sh a4, 6(s0)
    ret


system_interruption:
    # Save the context
    csrrw sp, mscratch, sp # Changes sp to mscratch
    addi sp, sp, -32
    
    # Parameters of our function play_note
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    sw a3, 12(sp)
    sw a4, 16(sp)

    # Numeric values used in interruption by GPT
    sw t0, 20(sp)
    sw t1, 24(sp)

    # Begin adress of MIDI base
    sw s0, 28(sp)

    jal GPT_interruption

    lw s0, 28(sp)

    lw t1, 24(sp)
    lw t0, 20(sp)

    lw a4, 16(sp)
    lw a3, 12(sp)
    lw a2, 8(sp)
    lw a1, 4(sp)
    lw a0, 0(sp)

    addi sp, sp, 32
    csrrw sp, mscratch, sp

    mret


_start:
    la t0, system_interruption # We load adress of our main IRS in register t0
    csrw mtvec, t0 # Now we load this adress in register mtvec

    jal GPT_interruption

    la t0, IRS_stack_end
    csrw mscratch, t0

    # Allow external interruptions
    csrr t1, mie # Set bit 11 (MEIE)
    li t2, 0x800
    or t1, t1, t2
    csrw mie, t1

    # Allow global interruptions
    csrr t1, mstatus # Set bit 3 (MIE)
    ori t1, t1, 0x8
    csrw mstatus, t1

    jal main


.data
_system_time: .word 0 # Initialize global time counter as zero

.bss
.align 4
IRS_stack: .skip 1024
IRS_stack_end:
.set BASE_GPT, 0xFFFF0100
.set BASE_MIDI, 0xFFFF0300