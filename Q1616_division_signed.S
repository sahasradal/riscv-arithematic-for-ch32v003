
.data
buffer: .word 0
buffer1: .word 0
result_lo: .word 0
result_hi: .word 0
modulo:    .word 0


.text
.align 2
    # Test with 16.6666 (0x0010aaaa)
#    li a0,688128		#10.5 * 65536
#    li a1,131072            	#2.0 * 65536
li a0,500
li a1,27
    call q16_div_signed
here:
    j here

# Input:  a0 = Dividend (A), a1 = Divisor (B)
# Output: a0 = Quotient (A/B in Q16.16) signed
# Scratches: t0, t1, t2, a2, a3
q16_div_signed:
    # 1. Determine sign of result (A ^ B)
    xor     a3, a0, a1    # If MSB is 1, result will be negative
    
    # 2. Get absolute value of A (a0)
    bgez    a0, .Ldiv_abs_b
    neg     a0, a0
    
.Ldiv_abs_b:
    # 3. Get absolute value of B (a1)
    bgez    a1, .Lstart_div
    neg     a1, a1

.Lstart_div:
    # 4. Prepare 64-bit Dividend (t1:t0) = a0 << 16
    # Correct 64-bit shift logic for RV32
    srli    t1, a0, 16    # High part of 64-bit (bits 31-16 of a0)
    slli    t0, a0, 16    # Low part of 64-bit (bits 15-0 of a0)
    
    li      a2, 0         # Clear quotient
    li      t2, 32        # Loop counter (bits to process)
    
.Ldiv_loop:
    # Shift 64-bit Dividend (t1:t0) left by 1
    # Get MSB of t0 to carry into t1
    srli    t3, t0, 31    
    slli    t1, t1, 1
    or      t1, t1, t3
    slli    t0, t0, 1
    
    # Shift Quotient (a2) left
    slli    a2, a2, 1
    
    # Compare High Dividend (t1) with Divisor (a1)
    bltu    t1, a1, .Lskip_sub
    sub     t1, t1, a1    # Subtract divisor
    ori     a2, a2, 1     # Set quotient bit
    
.Lskip_sub:
    addi    t2, t2, -1
    bnez    t2, .Ldiv_loop

    # 5. Apply Sign
    mv      a0, a2
    bgez    a3, .Ldiv_done
    neg     a0, a0        # If sign flag (a3) was negative, neg result
    
.Ldiv_done:
    ret
