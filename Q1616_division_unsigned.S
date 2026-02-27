
# works in rars
# input integer , output Q1616,tested on RARS
# Input:  a0 = Dividend (A), a1 = Divisor (B), input integer , output Q1616
# Output: a0 = Result (A/B in Q16.16)
# Scratches: t0, t1, t2, tp


.text
li a0,500
li a1,33
call q16_div

here:
j here


q16_div:
    # 1. Prepare 64-bit Dividend (t1:t0) = a0 << 16
    mv      t0, a0
    slli    t1, t0, 16    # t1 = Upper 32 bits of 64-bit dividend
    srli    t1, t0, 16    # This is wrong for signed; assuming unsigned for simplicity
    # Correct shift for 64-bit:
    srli    t1, a0, 16    # High 16 bits of A
    slli    t0, a0, 16    # Low 16 bits of A (now scaled)
    
    li      a0, 0         # Clear quotient
    li      t2, 32        # Loop counter
    
div_loop:
    # Shift 64-bit (t1:t0) left by 1
    slli    t1, t1, 1
    srli    tp, t0, 31    # Carry bit from t0 to t1
    or      t1, t1, tp
    slli    t0, t0, 1
    
    # Shift quotient (a0) left
    slli    a0, a0, 1
    
    # Compare high part with divisor
    bltu    t1, a1, skip_sub
    sub     t1, t1, a1    # Subtract divisor
    ori     a0, a0, 1     # Set quotient bit
    
skip_sub:
    addi    t2, t2, -1
    bnez    t2, div_loop
    ret

