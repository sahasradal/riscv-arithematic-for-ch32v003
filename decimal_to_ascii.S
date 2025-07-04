	li a0,0x80000000

convert_to_decimal:
    addi sp, sp, -16      # Reserve stack space (adjust size as needed)
    mv   gp, sp           # t1 = start of buffer
    addi gp, gp, 15       # Point to end of buffer (store digits backward)
    li   t2, 0            # Digit counter

digit_loop:
    call div_u10          # a0 = quotient, a1 = remainder (0-9)
    addi a1, a1, '0'      # Convert to ASCII
    sb   a1, 0(gp)        # Store digit at current position
    addi gp, gp, -1       # Move pointer left (next digit goes before)
    addi t2, t2, 1        # Increment digit count
    bnez a0, digit_loop   # Continue until quotient=0

    # Digits are now stored in correct order (no reversal needed)
    addi gp, gp, 1        # Adjust to first digit (e.g., "100" starts at t1)
    # t1 now points to the first ASCII digit
here:
	J here

# Input: a0 = number to divide (e.g., 100)
# Output: a0 = quotient (e.g., 10), a1 = remainder (e.g., 0)
div_u10:
    li    a1, 0           # Clear remainder
    li    t0, 31          # 32 bits to process
    mv    t1, a0          # t1 = working copy of input
    li    a0, 0           # a0 will store quotient

div_loop:
    # Build quotient in a0
    slli  a0, a0, 1       # Shift quotient left
    
    # Process next bit
    slli  t1, t1, 1       # Shift input left
    srli  t2, t1, 31      # Get MSB
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
