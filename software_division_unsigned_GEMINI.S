#Unsigned Division (Software udiv), GEMINI , untested  03/01/2026
#This routine provides both the quotient (in a0) and the remainder (in a1).
# Input: a0 = dividend, a1 = divisor
# Output: a0 = quotient, a1 = remainder
soft_div:
    li t0, 0            # t0 = quotient
    li t1, 32           # t1 = loop counter (32 bits)
    li t2, 0            # t2 = temporary remainder
div_loop:
    slli t2, t2, 1      # Shift temp remainder left
    srli t3, a0, 31     # Get MSB of dividend
    or   t2, t2, t3     # Pull MSB into temp remainder
    slli a0, a0, 1      # Shift dividend left
    
    bltu t2, a1, skip_sub
    sub  t2, t2, a1     # Subtract divisor if it fits
    ori  t0, t0, 1      # Set current quotient bit to 1
skip_sub:
    slli t0, t0, 1      # Prepare for next bit
    addi t1, t1, -1
    bnez t1, div_loop
    
    mv a1, t2           # a1 now holds the remainder
    srli a0, t0, 1      # a0 now holds the quotient
    ret
