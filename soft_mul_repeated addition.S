# here multiplicand stored in result1

	addi sp,sp,-36
	sw ra,0(sp)
	sw a0,4(sp)
	sw a1,8(sp)
	sw t0,12(sp)
	sw t1,16(sp)
	sw t2,20(sp)
	sw a5,24(sp)
	sw x3,28(sp)
	sw x4,32(sp)
multiply:
    	# a0 = multiplicand (32-bit)
    	# a1 = multiplier (32-bit)
    	# Returns:
    	# a0 = lower 32 bits of result
    	# a1 = upper 32 bits of result
	la a5,result1
 	lw a0,0(a5) 		# multiplicant
	beqz a0,exit_proc	# check multiplicant is 0
	bltz a0,exit_proc	# check multiplicant is -ve
 	li a1,60		# multiplier 0.0025

    	# Initialize result registers
    	li t0, 0     		# t0 = upper 32 bits of result (initially 0)
    	li t2, 0     		# t2 = lower 32 bits of result (initially 0)
    	mv t1, a0    		# t1 = multiplicand (copy of a0)
    	mv x3, a1    		# x3 = multiplier (copy of a1)

loop:
    	beq x3, zero, done 	# if multiplier is 0, we are done

    	# Add multiplicand to lower 32 bits of result
    	add x4, t2, t1  	# t4 = t2 + t1
    	sltu a2, x4, t2  	# t5 = carry (1 if t4 < t2)
    	add t0, t0, a2  	# add carry to upper 32 bits
    	mv t2, x4        	# update lower 32 bits

    	# Decrement multiplier
    	addi x3, x3, -1
    	j loop

exit_proc:
	li t2,0
	li t0,0
done:
    	mv a0, t2
    	mv a1, t0
	la a5,result_lo
	sw a0,0(a5)
	la a5,result_hi
	sw a1,0(a5)
	lw x4,32(sp)
	lw x3,28(sp)
	lw a5,24(sp)
	lw t2,20(sp)
	lw t1,16(sp)
	lw t0,12(sp)
	lw a1,8(sp)
	lw a0,4(sp)
	lw ra,0(sp)
	addi sp,sp,36
 	ret
