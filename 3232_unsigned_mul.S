# tested fine , all edge cases resolved, DS verified
.data 
buffer: .word 0
buffer1: .word 0
result_lo: .word 0
result_hi: .word 0
modulo:    .word 0

.text
    la a0, buffer
    li x7,0xdeadbeef
    sw x7, 0(a0)       # s0 = multiplicand (A)
    la a0, buffer1
    li x7,0xffff0000
    sw x7, 0(a0)       # s1 = multiplier (B)
    call multiply
here:
	j here





multiply:
    # Save registers
    addi sp, sp, -24
    sw ra, 0(sp)
    sw x3, 4(sp)	#x3
    sw x4, 8(sp)	#x4
    sw x5, 12(sp)	#x5
    sw x6, 16(sp)	#x6
    sw x7, 20(sp)	#x7

    # Load operands
    la a0, buffer
    lw x3, 0(a0)       # s0 = multiplicand (A)
    la a0, buffer1
    lw x4, 0(a0)       # s1 = multiplier (B)
    
    # Initialize registers
    li x5, 0           # s2 = hi part of result
    li x6, 0           # s3 = lo part of result
    li x7, 0           # s4 = carry flag
    li a5, 32          # t0 = counter (32 bits)

mult_loop:
    # Check LSB of multiplier
    andi a4, x4, 1	# t1=a4
    beqz a4, shift_only

    # Add multiplicand to hi with carry
    add x5, x5, x3     # hi += multiplicand
    sltu x7, x5, x3    # set carry if overflow (s4 = 1 if carry)

shift_only:
    # Shift the 64-bit result right by 1
    # First prepare what will become the new MSB of hi
    slli a4, x7, 31    # move carry to MSB position
    
    # Save current LSB of hi for lo shift
    andi a3, x5, 1     # t2=a3
    
    # Shift hi (including carry)
    srli x5, x5, 1     # shift hi right
    or x5, x5, a4      # insert carry
    
    # Shift lo (taking bit from hi)
    srli x6, x6, 1     # shift lo right
    slli a3, a3, 31    # move hi's LSB to MSB position
    or x6, x6, a3      # insert into lo
    
    # Prepare carry for next iteration
    mv x7, a3          # carry = the bit we just shifted into lo
    
    # Shift multiplier
    srli x4, x4, 1
    
    # Decrement counter
    addi a5, a5, -1
    bnez a5, mult_loop

    # Store results
    la a0, result_hi
    sw x5, 0(a0)
    la a0, result_lo
    sw x6, 0(a0)

    # Restore registers
    lw ra, 0(sp)
    lw x3, 4(sp)
    lw x4, 8(sp)
    lw x5, 12(sp)
    lw x6, 16(sp)
    lw x7, 20(sp)
    addi sp, sp, 24
    ret