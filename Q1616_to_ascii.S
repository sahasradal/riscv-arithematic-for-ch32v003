.text
.align 2
    # Test with 16.6666 (0x0010aaaa)
    li a0, 0x0010aaaa
    call print_q1616
here:
    j here

.global print_q1616
print_q1616:
    addi sp, sp, -12
    sw   ra, 8(sp)
    sw   s0, 4(sp)
    sw   s1, 0(sp)

    mv   s0, a0            # s0 = input Q16.16
    
    # 1. Sign
    bgez s0, .Lpos16
    li   a0, '-'
    jal  ra, putchar
    neg  s0, s0
.Lpos16:

    # 2. Integer Part (Top 16 bits)
    srli a0, s0, 16        
    jal  ra, .Lprint_int_16bit

    # 3. Decimal Point
    li   a0, '.'
    jal  ra, putchar

    # 4. Fractional Part (Lower 16 bits)
    li t0, 0xffff
    and a0, s0, t0
    
    # Multiply x by 3125 / 2048 to get 0-99999
    slli t0, a0, 11        # x * 2048
    slli t1, a0, 10
    add t0, t0, t1 	       # + 1024
    slli t1, a0, 5
    add t0, t0, t1 	       # + 32
    slli t1, a0, 4
    add t0, t0, t1 	       # + 16
    slli t1, a0, 2
    add t0, t0, t1 	       # + 4
    add  t0, t0, a0            # + 1
    srli a0, t0, 11        
    
    # 5. Print 5 fractional digits
    jal  ra, .Lprint_dec_5digit

    lw   s1, 0(sp)
    lw   s0, 4(sp)
    lw   ra, 8(sp)
    addi sp, sp, 12
    ret

# --- Helper: Print 16-bit Int (Corrected) ---
.Lprint_int_16bit:
    addi sp, sp, -4
    sw   ra, 0(sp)         
    mv   t2, a0
    li   s1, 0             # Leading zero flag
    
    # Check 10000s
    li   t0, 10000
    jal  ra, .Ldo_digit
    # Check 1000s
    li   t0, 1000
    jal  ra, .Ldo_digit
    # Check 100s
    li   t0, 100
    jal  ra, .Ldo_digit
    # Check 10s
    li   t0, 10
    jal  ra, .Ldo_digit
    
    # Final Ones digit (ALWAYS print this, even if 0, so "0.5" works)
    addi a0, t2, '0'       
    jal  ra, putchar
    
    lw   ra, 0(sp)
    addi sp, sp, 4
    ret

.Ldo_digit:
    li   t1, '0'
b1: bltu t2, t0, b2
    sub  t2, t2, t0
    addi t1, t1, 1
    li   s1, 1             # Set flag: we've started printing digits
    j    b1
b2: beqz s1, b3            # Suppress leading zeros
    mv   a0, t1
    addi sp, sp, -12
    sw   t2, 8(sp)  
    sw   ra, 4(sp)         # SAVE RA because we call putchar
    sw   t0, 0(sp)
    jal  ra, putchar
    lw   t0, 0(sp)
    lw   ra, 4(sp)
    lw   t2, 8(sp)
    addi sp, sp, 12
b3: ret

# --- Helper: Print Exactly 5 Digits ---
.Lprint_dec_5digit:
    addi sp, sp, -4
    sw   ra, 0(sp)
    mv   t2, a0            
    li   t0, 10000
    jal  ra, .Ldo_digit_padded
    li   t0, 1000
    jal  ra, .Ldo_digit_padded
    li   t0, 100
    jal  ra, .Ldo_digit_padded
    li   t0, 10
    jal  ra, .Ldo_digit_padded
    addi a0, t2, '0'
    jal  ra, putchar
    lw   ra, 0(sp)
    addi sp, sp, 4
    ret

.Ldo_digit_padded:
    li   t1, '0'
d1: bltu t2, t0, d2
    sub  t2, t2, t0
    addi t1, t1, 1
    j    d1
d2: mv   a0, t1
    addi sp, sp, -12
    sw   t2, 8(sp)
    sw   ra, 4(sp)         # SAVE RA
    sw   t0, 0(sp)
    jal  ra, putchar
    lw   t0, 0(sp)
    lw   ra, 4(sp)
    lw   t2, 8(sp)
    addi sp, sp, 12
    ret

putchar:
    li a7, 11       
    ecall           
    ret
