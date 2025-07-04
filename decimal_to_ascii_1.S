# Input: a0 = unsigned 32-bit number
# Output: ASCII string stored at buffer (sp)
    li a0,0xffffffff
convert_to_decimal:
    addi sp, sp, -16
    mv   tp, sp           # t1 = start of buffer (store digits forward)
    li   t2, 0

digit_loop:
    call div_u10
    addi a1, a1, '0'
    sb   a1, 0(tp)        # Store digit at t1
    addi tp, tp, 1        # Move pointer right
    addi t2, t2, 1
    bnez a0, digit_loop


# Input: a0 = number to divide (e.g., 100)
# Output: a0 = quotient (e.g., 10), a1 = remainder (e.g., 0)
div_u10:
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
    li    t2, 10
    bltu  a1, t2, skip_sub
    
    # Adjust remainder and set quotient bit
    sub   a1, a1, t2
    ori   a0, a0, 1       # Set LSB of quotient
    
skip_sub:
    addi  t0, t0, -1
    bnez  t0, div_loop
    
    ret

