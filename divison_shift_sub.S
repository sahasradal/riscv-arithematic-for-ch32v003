li a0,200
li tp,20
# Input: a0 = dividend ,    tp = divisor 
# Output: a0 = quotient , tp = remainder 
div_u10:
    addi sp,sp,-16
    sw ra,0(sp)
    sw a1,4(sp)
    sw t0,8(sp)
    sw gp,12(sp)
    sw t2,16(sp)
    

    li    a1, 0           # Clear remainder
    li    t0, 32          # 32 bits to process
    mv    gp, a0          # gp = working copy of input
    li    a0, 0           # a0 will store quotient

div_loop:
    # Build quotient in a0
    slli  a0, a0, 1       # Shift quotient left
    
    # Process next bit

    srli  t2, gp, 31      # Get MSB
    slli  gp, gp, 1       # Shift input left
    slli  a1, a1, 1       # Shift remainder left
    or    a1, a1, t2      # Insert new bit
    
    # Check if remainder >= 10
    mv    t2, tp
    bltu  a1, t2, skip_sub
    
    # Adjust remainder and set quotient bit
    sub   a1, a1, t2
    ori   a0, a0, 1       # Set LSB of quotient
    
skip_sub:
    addi  t0, t0, -1
    bnez  t0, div_loop
    mv tp,a1              # reminder transferred to tp(x3)
    lw t2,16(sp)
    lw gp,12(sp)
    lw t0,8(sp)
    lw a1,4(sp)
    lw ra,0(sp)
    addi sp,sp,16
    ret

