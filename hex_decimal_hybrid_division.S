#division , gives result in  "Hex-Decimal" hybrid. integer is hex and fraction is decimal. but not good for general programming.
.data 
buffer: .word 0
buffer1: .word 0
result_lo: .word 0
result_hi: .word 0
modulo:    .word 0
qoutient:  .word 0

.text

li a0,1000
li tp,33
# Input: a0 = dividend ,    tp = divisor 
# Output: a0 = quotient , tp = remainder 
div_routine:
call div_u10
la a1,qoutient
lw a0,0(a1)
la a1,buffer
#slli a0,a0,16   #shift integer part to upper 16 bits for Q1616
sw a0,0(a1)
beqz tp,here  # branch to here if no remainder
li t2,4
j fraction
frac_div_routine:
call div_u10
la a1,qoutient
lw a0,0(a1)
la a1,buffer
lw a2,0(a1)
slli a2,a2,4
or a0,a0,a2
sw a0,0(a1)
addi t2,t2,-1
beqz t2 , here
fraction:
la a1,modulo
lw s0,0(a1)
mult10:
slli t0, s0, 3    # t0 = x * 8
slli t1, s0, 1    # t1 = x * 2
add  a0, t0, t1    # a0 = 8x + 2x = 10x
bge a0,tp,frac_div_routine
mv s0,a0
la a1,buffer
lw a2,0(a1)
slli a2,a2,4
sw a2,0(a1)
addi t2,t2,-1
beqz t2 , here
blt s0,tp,mult10


here:
J here




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
    #mv tp,a1              # reminder transferred to tp(x3)
    la t0,qoutient
    sw a0,0(t0)
    la t0,modulo
    sw a1,0(t0)
    lw t2,16(sp)
    lw gp,12(sp)
    lw t0,8(sp)
    lw a1,4(sp)
    lw ra,0(sp)
    addi sp,sp,16
    ret




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


