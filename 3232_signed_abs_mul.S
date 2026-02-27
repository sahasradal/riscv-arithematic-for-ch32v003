
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
    call multiply
here:
	j here







signed_multiply_abs_correct:
    addi sp, sp, -32
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)
    sw s5, 24(sp)
    sw s6, 28(sp)

    # Load A and B
    la a0, buffer
    lw s0, 0(a0)           # A = multiplicand
    la a0, buffer1
    lw s1, 0(a0)           # B = multiplier

    # sign = (A < 0) XOR (B < 0)
    srai s5, s0, 31        # -1 if A negative, 0 otherwise
    srai s6, s1, 31        # -1 if B negative
    xor  s4, s5, s6        # -1 = result negative, 0 = positive

    # A = abs(A)
    xor  s0, s0, s5
    sub  s0, s0, s5

    # B = abs(B)
    xor  s1, s1, s6
    sub  s1, s1, s6

    # Now unsigned multiply on abs values
    li s2, 0               # hi
    li s3, 0               # lo
    li t0, 32              # counter

mult_loop:
    andi t1, s1, 1
    li t2, 0               # carry = 0 (reset here)
    beqz t1, shift_only

    add s2, s2, s0
    sltu t2, s2, s0        # carry = sltu if add

shift_only:
    slli t1, t2, 31        # carry to MSB pos
    andi t3, s2, 1         # old hi LSB
    srli s2, s2, 1
    or s2, s2, t1          # insert into hi

    srli s3, s3, 1
    slli t3, t3, 31
    or s3, s3, t3          # insert into lo

    # REMOVED: mv t2, t3 (or equivalent)

    srli s1, s1, 1

    addi t0, t0, -1
    bnez t0, mult_loop

    # Apply sign
    bgez s4, store
    not s3, s3
    not s2, s2
    addi s3, s3, 1
    sltiu t0, s3, 1
    add s2, s2, t0

store:
    la a0, result_hi
    sw s2, 0(a0)
    la a0, result_lo
    sw s3, 0(a0)

    # Restore
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    lw s5, 24(sp)
    lw s6, 28(sp)
    addi sp, sp, 32
    ret