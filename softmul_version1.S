# soft multiplication shift and add method with 2n register and carry implementation.

.text
	addi sp,sp,-52
	sw ra,0(sp)
	sw a0,4(sp)
	sw a1,8(sp)
	sw a2,12(sp)
	sw a3,16(sp)
	sw a4,20(sp)
	sw a5,24(sp)
	sw x3,28(sp)
	sw x4,32(sp)
	sw x5,36(sp)
	sw x6,40(sp)
	sw x7,44(sp)
	sw x8,48(sp)

	la a0,result1
 	lw a1,0(a0) 		# multiplicant
	la a0,scratchpad
 	lw a2,0(a0)		# multiplier calculated by calibration in setup
 	li a3,0x00000000 	# result_lo
 	li a4,0x00000000 	# result_hi
 	li a5,0			# working register 
 
rational_check:
	beqz a1,mul_by_zero
	beqz a2,mul_by_zero
	 
############################
 
 	li x5,32		# number of bits to be tested/counter
loop:
 	mv x3,a2		# copy multiplier to test lsb 1 or 0
	andi x3,x3,1		# extract lsb in x3
	bnez x3,addnshift1	# if x3 is 1 branch to add and shift
	call shift		# if x3 is 0 call routine to shift result hi and lo + carry register right
	addi x5,x5,-1		# decrease counter
	bnez x5,loop		# if counter is not 0 go to label loop
	slli x6,x6,1		# if counter is 0, shift carry register left 1 time ( i dont know why but corrects answer)
	j exit			# exit multiplication procedure
addnshift1:
	call addnshift		# call addnshift routine to add multiplicand to result_hi and shift both result_hi & result_lo
	addi x5,x5,-1		# decrease counter
	bnez x5,loop		# if counter is more than 0 branch to label loop
	slli x6,x6,1		# if counter is 0, shift carry register left 1 time ( i dont know why but corrects answer)
	j exit			# exit multiplication procedure



shift:
	srli a2,a2,1		# multiplier right shift, 1 lsb lost
	srli a3,a3,1		# 2n low register(a3) right shift and 0 in msb (a4:a3)
	mv x4,a4		# a copy of high 2n register(a4) to x4 (a4:a3)
	andi x4,x4,1		# copy lsb of a4 high 2n register
	beqz x4,lsb0		# if lsb extracted is 0 , branch to lsb0 label
	li x4,0x80000000	# if lsb of a4 was 1
	or a3,a3,x4		# lsb of a4 now in msb of a3. (a4:a3 >> 1)
lsb0:
	srli a4,a4,1		# 2n high register right shift ,same as 0 shifted between a4 to a3 >>
	srli x6,x6,1		# shift right carry register together with a4:a3
	ret			# return to main program


addnshift:
	add a4,a4,a1		# add multiplicand to high 2n register
 	sltu x8 a4,a1		# set x8 to 1 if result of addition (a4 + a1) answer_hi and multiplicand
	bnez x8,setcarry	# if x8 is not 0 , branch to setcarry label
return:
	srli a2,a2,1		# multiplier right shift
	srli a3,a3,1		# 2n low register right shift and 0 in msb
	mv x4,a4		# a copy of lw 2n
	andi x4,x4,1		# copy lsb of a4 high 2n register
	beqz x4,addlsb0		# if lsb extracted is 0 , branch to addlsb0 label 
	li x4,0x80000000	# if lsb of a4 was 1
	or a3,a3,x4		# lsb of a4 now in msb of a3. (a4:a3 >> 1)
addlsb0:
	srli a4,a4,1		# 2n high register right shift
	srli x6,x6,1		# shift right carry register together with a4:a3
	ret			# return to main program
setcarry:
	li x7,0x80000000	# set msb of x7 with 0x80000000
	or x6,x6,x7		# set msb of x7 by oring t6 with x7
	j return		# jump to shifing routine

mul_by_zero:
	li a4,0			# load 0 as multiplicand or multiplier is 0
	li a3,0 		# load 0 as multiplicand or multiplier is 0
	li x6,0 		# load 0 as multiplicand or multiplier is 0

exit:
	beqz x6,nocarry		# if t6 is not set , 0 , no overflow occured, branch to nocarry
	mv a4,x6		# if carry set , copy t6 to answer hi register
nocarry:
	la a0,result_hi		# 
	sw a4,0(a0)		# save to data section
	la a0,result_lo
	sw a3,0(a0)		# save to data section
exit_proc:
	lw x8,48(sp)
	lw x7,44(sp)
	lw x6,40(sp)
	lw x5,36(sp)
	lw x4,32(sp)
	lw x3,28(sp)
	lw a5,24(sp)
	lw a4,20(sp)
	lw a3,16(sp)
	lw a2,12(sp)
	lw a1,8(sp)
	lw a0,4(sp)
	lw ra,0(sp)
	addi sp,sp,52
 	ret
 


 
