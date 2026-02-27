# tested fine , all edge cases resolved, DS verified , 31 register version
.data 
buffer: .word 0
buffer1: .word 0
result_lo: .word 0
result_hi: .word 0
modulo:    .word 0

.text
    la a0, buffer
    li x7,0xffff0000           #0xdeadbeef
    sw x7, 0(a0)       # s0 = multiplicand (A)
    la a0, buffer1
    li x7,0x00008000	       #0xffffffff
    sw x7, 0(a0)       # s1 = multiplier (B)
    call multiply
here:
	j here





multiply:
    # Save registers
    addi sp, sp, -24
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)

    # Load operands
    la a0, buffer
    lw s0, 0(a0)       # s0 = multiplicand (A)
    la a0, buffer1
    lw s1, 0(a0)       # s1 = multiplier (B)
    
    # Initialize registers
    li s2, 0           # s2 = hi part of result
    li s3, 0           # s3 = lo part of result
    li s4, 0           # s4 = carry flag
    li t0, 32          # t0 = counter (32 bits)

mult_loop:
    # Check LSB of multiplier
    andi t1, s1, 1
    beqz t1, shift_only

    # Add multiplicand to hi with carry
    add s2, s2, s0     # hi += multiplicand
    sltu s4, s2, s0    # set carry if overflow (s4 = 1 if carry)

shift_only:
    # Shift the 64-bit result right by 1
    # First prepare what will become the new MSB of hi
    slli t1, s4, 31    # move carry to MSB position
    
    # Save current LSB of hi for lo shift
    andi t2, s2, 1
    
    # Shift hi (including carry)
    srli s2, s2, 1     # shift hi right
    or s2, s2, t1      # insert carry
    
    # Shift lo (taking bit from hi)
    srli s3, s3, 1     # shift lo right
    slli t2, t2, 31    # move hi's LSB to MSB position
    or s3, s3, t2      # insert into lo
    
    # Prepare carry for next iteration
    mv s4, t2          # carry = the bit we just shifted into lo
    
    # Shift multiplier
    srli s1, s1, 1
    
    # Decrement counter
    addi t0, t0, -1
    bnez t0, mult_loop

    # Store results
    la a0, result_hi
    sw s2, 0(a0)
    la a0, result_lo
    sw s3, 0(a0)

    # Restore registers
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    addi sp, sp, 24
    ret







########################################
#RISC-V Sign-Extension:
#assembly
# Assume a0 contains the 16-bit raw value from INA231 (e.g., 0xFFFE for -2)
#slli a0, a0, 16
#srai a0, a0, 16    # a0 is now 0xFFFFFFFE (-2 in 32-bit)
#Optimization for Constant 2500 Because 2500 is a fixed constant, you can replace the entire 32-loop multiply call with a faster sequence of shifts and adds. Mathematically:\(2500=2048+256+128+64+4\)\(2500=(x\ll 11)+(x\ll 8)+(x\ll 7)+(x\ll 6)+(x\ll 2)\) In RISC-V assembly, this would look like: assembly# Input in a0 (INA231 Register Value)
#slli t0, a0, 11    # t0 = x * 2048
#slli t1, a0, 8     # t1 = x * 256
#add  t0, t0, t1    # t0 = x * (2048 + 256)
#slli t1, a0, 7     # t1 = x * 128
#add  t0, t0, t1    # t0 = x * (2304 + 128)
#slli t1, a0, 6     # t1 = x * 64
#add  t0, t0, t1    # t0 = x * (2432 + 64)
#slli t1, a0, 2     # t1 = x * 4
#add  a0, t0, t1    # final a0 = x * 2500
#Use code with caution.Pros: Runs in ~10 cycles instead of ~300+ cycles in your loop.Cons: Only works for the specific constant 2500.


# --- STEP 1: Run your multiply routine as discussed before ---
# After 'final_done', the signed 64-bit result is in result_hi:result_lo

# --- STEP 2: Subtract 10,000 uA Offset ---
#la   t0, result_lo
#lw   t1, 0(t0)        # Load lower 32-bit result (measured_ua)
#la   t2, result_hi
#lw   t3, 0(t2)        # Load upper 32-bit result

#li   t4, 10000        # The 10mA offset in microamps

# Perform 64-bit subtraction (Measured - Offset)
#sltu t5, t1, t4       # Generate borrow: t5 = 1 if t1 < 10000
#sub  t1, t1, t4       # result_lo = result_lo - 10000
#sub  t3, t3, t5       # result_hi = result_hi - borrow

# --- STEP 3: Store the Final True Current ---
#sw   t1, 0(t0)
#sw   t3, 0(t2)
####################

# Before calling multiply:
#mv s10, zero            # Flag for sign (0 = positive, 1 = negative)
#bgez a0, skip_negate    # If a0 >= 0, skip
#li s10, 1               # Mark as negative
#neg a0, a0              # Convert to positive (abs value)
#skip_negate:
# Store a0 in 'buffer' and call your multiply routine...

# After multiply returns:
#beqz s10, final_done    # If it was positive, we are done
# Negate the 64-bit result (result_hi:result_lo)
#la t0, result_lo
#lw t1, 0(t0)
#la t2, result_hi
#lw t3, 0(t2)

#not t1, t1              # Bitwise NOT lo
#not t3, t3              # Bitwise NOT hi
#addi t1, t1, 1          # Add 1 to lo for 2's complement
#sltu t4, t1, zero       # Check for carry from lo to hi
#add t3, t3, t4          # Add carry to hi

#sw t1, 0(t0)            # Store back
#sw t3, 0(t2)
#final_done:
###########################
