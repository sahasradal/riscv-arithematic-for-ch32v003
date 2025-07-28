# tested on rars , works but very cumbersome
.data
result_lo: .word 0
result_hi: .word 0
modulo: .word 0

.text
	li a1,100     	 	# number to be dividend
	li a2,21		 # divisor
	li a3,0x01		 # result & also used to count
	li a4,0		 	 # result hi register
	li a5,0			 # workig register/remainder

division_loop:
	li x3,0			# clear carry ,x3 is carry register
	call ROLa1		# rotate left a1 register
	call ROLa5		# rotate left a5 register
	bnez x3,div32b		# if carry is set ,branch to div32b
	mv t0,a2		# copy divisor a2 to t0
	mv t1,a5		# copy working register to t1
	#sub t2,t1,t0
	sltu x3,t1,t0		# set x3(carry) to 1 if t1 is less than t0 ,if a subtraction will result in borrow x3 is set
	bnez x3,div32c		# if carry set branch to div32c
div32b:
	mv t0,a2		# move divisor to t0
	mv t1,a5		# move working register to t1
	sub t2,t1,t0		# subtract divisor from work register
	mv a5,t2		# update the change in t2 to a5
	li x3,1			# set carry bit
	j div32d		# jump to div32d
div32c:
	li x3,0			# clear carry
div32d:
	call ROLa3		# rotate a3 left
	beqz x3,division_loop	# if carry is clear we have not reached the 1 we loaded in the a3 result register at the set up time
	la t0,result_lo		# let t0 point to result_lo
	sw a3,0(t0)		# store result of division in address  pointed by t0
	la t0,modulo		# point to address of modulo
	sw a5,0(t0)		# a5 has remainder of division 
here:
	j here

#SUBROOUTINES

ROLa1:
	li x3,0			# clear carry
	mv t1,a1		# we need to rotate a1 through carry. copy a1 to t1
	li t0,0x80000000	# extract the MSB with bitmask 0x80000000
	and t1,t1,t0		# ANDing t1 with t0 extracts the MSB
	bnez t1,setcarry1	# if t1 is not 0, MSB is 1 else MSB is 0. If 1 branch to setcarry1
	slli a1,a1,1		# a 0 is shifted to lsb and x3 (carry) stays 0 if previous operation resulted 0 in t1
	ret			# return to caller
setcarry1:
	li x3,1			# set carry , load 1 in x3 as above left shift resulted in 1 
	slli a1,a1,1		# shift a1 1 step left, 0 is shifted into lsb and carry has the 1 shifted out from msb
	ret			# return to caller

ROLa5:
	mv t1,a5		# we need to rotate a5 through carry. copy a5 to t1
	li t0,0x80000000	# extract the MSB with bitmask 0x80000000
	and t1,t1,t0		# ANDing t1 with t0 extracts the MSB
	bnez t1,setcarry2	# if t1 is not 0, MSB is 1 else MSB is 0. If 1 branch to setcarry2
	slli a5,a5,1		# a 0 is shifted to lsb and x3 (carry) stays 0 if previous operation resulted 0 in t1
	or a5,a5,x3		# shift in bit in carry by ORing x3. this bit in carry is from previous subroutine call
	li x3,0			# clear carry as bit in carry now has been shifted to a5 lsb
	ret			# return to caller
setcarry2:
	slli a5,a5,1		# we reach here if msb of a5 is 1, shift a5 1 step left
	or a5,a5,x3		# shift lhs a5 1 step
	li x3,1			# set carry to 1
	ret			# return to caller

ROLa3:
	mv t1,a3		# move result register to t1
	li t0,0x80000000	# load bit mask for top bit
	and t1,t1,t0		# and t1 and t0 to extract msb
	bnez t1,setcarry3	# if t1 is not 0, branch to setcarry2
	slli a3,a3,1		# left shift a3 1 step
	or a3,a3,x3		# OR in bit stored in x3(carry) from previous subroutine
	li x3,0			# clear carry, 0 shifted out from from msb is stored 
	ret			# return to caller
setcarry3:
	slli a3,a3,1		# shift a3 to left to OR in the bit in carry
	or a3,a3,x3		# shift in the bit in carry to lsb
	li x3,1			# set carry to 1 as msb of a3 waas 1
	ret			# return to caller
