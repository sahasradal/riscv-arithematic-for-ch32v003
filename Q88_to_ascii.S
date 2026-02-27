#This is a complete, standalone assembly function for the CH32V003 (RV32EC). It converts a signed Q8.8 value into a human-readable ASCII string (e.g., -12.500) and sends it via a putchar function.
#1. The Strategy
#Sign: Check if negative, print -, and negate.
#Integer: Divide the top 8 bits by 100, 10, and 1 using subtraction (since div is missing).
#Fraction: Use the 125/32 multiplier to turn the 8-bit fraction into a 3-digit integer (0-999), then print those three digits.
#2. Standalone Assembly (print_q88.s)


# CH32V003 Q8.8 to ASCII Utility
# Coding Style: GNU Assembler (gas)

.text
.align 2
    # Test with 16.6666 (0x0010aaaa)
    li a0, 0x0010aa
    call print_q88
here:
    j here
.global print_q88
print_q88:
    # Save return address (ra) and s0 (our value holder)
    addi sp, sp, -8
    sw   ra, 4(sp)
    sw   s0, 0(sp)

    mv   s0, a0            # s0 = input value
    
    # 1. Handle Negative Sign
    bgez s0, .Lprint_int_part
    li   a0, '-'
    jal  ra, putchar
    neg  s0, s0            # Make s0 positive for math

.Lprint_int_part:
    srli a0, s0, 8         # a0 = Integer part (0-127)
    jal  ra, .Lprint_dec_8bit

    # 2. Print Decimal Point
    li   a0, '.'
    jal  ra, putchar

    # 3. Fractional Part: Convert 0-255 to 0-999 milli-units
    # Formula: (fraction * 125) >> 5
    andi a0, s0, 0xFF      # a0 = raw fraction bits
    
    # Multiply x by 125: (x << 7) - (x << 2) + x
    slli t0, a0, 7         # x * 128
    slli t1, a0, 2         # x * 4
    sub  t0, t0, t1        # x * 124
    add  t0, t0, a0        # x * 125
    srli a0, t0, 5         # Result is 0 to 999
    
    # 4. Print 3 fractional digits (including leading zeros)
    jal  ra, .Lprint_dec_3digit

    # Restore and Return
    lw   s0, 0(sp)
    lw   ra, 4(sp)
    addi sp, sp, 8
    ret

# --- Helper: Print 0-255 as Decimal ---
.Lprint_dec_8bit:
    mv   t2, a0            # t2 = working value
    li   t3, 0             # Suppress leading zero flag
    
    # Hundreds
    li   t0, 100
    li   t1, '0'
b1:  bltu t2, t0, b2
    sub  t2, t2, t0
    addi t1, t1, 1
    li   t3, 1             # Found a non-zero digit
    j    b1
b2:  beqz t3, b3            # Skip if leading zero
    mv   a0, t1
    sw   t2, -4(sp)
    sw t3, -8(sp) 	    # Save temp regs before call
    jal  ra, putchar
    lw   t3, -8(sp)
    lw t2, -4(sp)
    
b3:  # Tens
    li   t0, 10
    li   t1, '0'
b4:  bltu t2, t0, b5
    sub  t2, t2, t0
    addi t1, t1, 1
    li   t3, 1
    j    b4
b5:  beqz t3, b6
    mv   a0, t1
    sw   t2, -4(sp)
    jal  ra, putchar
    lw   t2, -4(sp)
    
b6:  # Ones (Always print)
    addi a0, t2, '0'
    jal ra,    putchar
ret
# --- Helper: Print 0-999 with Zero Padding ---
.Lprint_dec_3digit:
    mv   t2, a0            # t2 = value (0-999)
    
    # Hundreds (Always print even if 0)
    li   t0, 100
    li   t1, '0'
bb1:  bltu t2, t0, bb2
    sub  t2, t2, t0
    addi t1, t1, 1
    j    bb1
bb2:  mv   a0, t1
    sw   t2, -4(sp)
    jal ra, putchar
    lw t2, -4(sp)

    # Tens (Always print)
    li   t0, 10
    li   t1, '0'
bb3:  bltu t2, t0, bb4
    sub  t2, t2, t0
    addi t1, t1, 1
    j    bb3
bb4:  mv   a0, t1
    sw   t2, -4(sp)
    jal ra, putchar
    lw t2, -4(sp)

    # Ones (Always print)
    addi a0, t2, '0'
    jal ra    putchar
    ret


putchar:
    li a7, 11       
    ecall           
    ret
