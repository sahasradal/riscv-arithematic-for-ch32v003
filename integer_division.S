integer division
.data
state: .word 0

.text
#######################################################################################################
# division routine, load divisor and dividend in sram before calling, result in state register ,sram
#########################################################################################################

# a1 = nimber1 # low
# a2 = number2 # high
# a5 = workreg
# a3= low register = a2:a1
# a4 =hi register = a4:a3
# t1 carry

division:
	addi sp,sp,-24
	sw a1,20(sp)
	sw a2,16(sp)
	sw a3,12(sp)
	sw a4,8(sp)
	sw a5,4(sp)
	sw t1,0(sp)
	li t1,0				# initialize t1 to 0
	li t2,0				# initialize t2 to 0
	li a2,0				# initialize a2 to 0
	li a4,0				# initialize a4 to 0
	li a5,0				# initialize a5 to 0 
	la x10,dividend			# numerator loaded here
	lw a1,0(x10)			# divident x11
	la x10,divisor			# divisor in result1,x10 points to sram result1
	lw a3,0(x10)			# load word in state to x13(divisor)
X:
	sub a5,a1,a3			# subtract divisor from dividend and store remainder in a5
	sltu t1,a1,a3			# set t1 if a1 is less than a3
	bnez t1,carry			# if t1 not equal 0 branch to carry
	mv a1,a5			# move remainder to a1 from a5
	sub a5,a2,a4			# subtract the high registers a4 from a2
	addi t2,t2,1			# increase t2 by 1 for each successful subtraction (result)
	J X				# loop to X till t1 is set
carry:
	la t0, state			# load address of state in t0
	sw t2,0(t0)			# store result in t2 in state
#	la t0, result2			# load address of result2 in t0
#	sw a1,0(t0)			# store a1 high byte of result in result2 = 0
	lw t1,0(sp)
	lw a5,4(sp)
	lw a4,8(sp)
	lw a3,12(sp)
	lw a2,16(sp)
	lw a1,20(sp)
	addi sp,sp,24
	ret
