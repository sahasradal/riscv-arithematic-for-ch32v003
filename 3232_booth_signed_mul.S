
.data 
buffer: .word 0
buffer1: .word 0
result_lo: .word 0
result_hi: .word 0
modulo:    .word 0

.text
    la a0, buffer
    li x7,0xdeadbeef
    sw x7, 0(a0)       # s0 = multiplicand (A)
    la a0, buffer1
    li x7,0xffff0000
    sw x7, 0(a0)       # s1 = multiplier (B)
    call signed_multiply_booth
here:
	j here









signed_multiply_booth:
    addi sp, sp, -28
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw a2, 12(sp) 
    sw a3, 16(sp) 
    sw a4, 20(sp)
    sw a5, 24(sp)

    # Load operands
    la a0, buffer
    lw s0, 0(a0)       # multiplicand M (signed)
    la a0, buffer1
    lw s1, 0(a0)       # multiplier Q (signed)

    # Initialize
    li a2, 0           # A (accumulator, hi)
    mv a3, s1          # Q (lo)
    li a4, 0           # Q-1 (extra bit)
    li a5, 32          # counter

booth_loop:
    # Get bits Q0 and Q-1
    andi t0, a3, 1     # Q0
    mv t1, t0          # temp Q0
    slli t0, t0, 1     # Q0 << 1
    or t0, t0, a4      # bits = Q0:Q-1

    # Decide action
    li t2, 1           # 01: add M
    beq t0, t2, add_m
    li t2, 2           # 10: sub M
    beq t0, t2, sub_m
    j shift            # 00 or 11: no op

add_m:
    add a2, a2, s0
    j shift

sub_m:
    sub a2, a2, s0
    j shift

shift:
    # Update Q-1 for next = old Q0
    mv a4, t1

    # Arithmetic right shift of A:Q (64-bit signed)
    andi t0, a2, 1     # A LSB for Q MSB
    srai a2, a2, 1     # A >>= 1 (arithmetic, preserves sign)
    slli t0, t0, 31    # to MSB pos
    srli a3, a3, 1     # Q >>= 1
    or a3, a3, t0      # insert old A LSB into Q MSB

    addi a5, a5, -1
    bnez a5, booth_loop

    # Store results (s2: hi, s3: lo)
    la a0, result_hi
    sw a2, 0(a0)
    la a0, result_lo
    sw a3, 0(a0)

    # Restore registers
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw a2, 12(sp)
    lw a3, 16(sp)
    lw a4, 20(sp)
    lw a5, 24(sp)
    addi sp, sp, 28
    ret