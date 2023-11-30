# first integer in result1 and its fraction in fraction
# 2nd integer in result_lo and its fraction in fraction2


.data
result1: .word 0
result2: .word 0
result_lo: .word 0
result_hi: .word 0
modulo: .word 0
fraction: .word 0
result_lo_m: .word 0
result_hi_m: .word 0
fraction2: .word 0
sign: .word 0

.text

la t0,result1
li x7,3000
sw x7,0(t0)
la t0,fraction
li x7,300
sw x7,0(t0)
la t0,result_lo
li x7,200
sw x7,0(t0)
la t0,fraction2
li x7,700
sw x7,0(t0)

la t0,result1
lw a1,0(t0)
la t0,fraction
lw a2,0(t0)
la t0,result_lo
lw a3,0(t0)
la t0,fraction2
lw a4,0(t0)

bge a2,a4,positive_frac		# compare fraction
addi a2,a2,1000
sub a2,a2,a4
addi a1,a1,-1
la t0,fraction			# fraction stored in fraction
sw a2,0(t0)
la t0,result1			# modified a1 write back to result1
sw a1,0(t0)	

checkint:
bge a1,a3,positiveint		# if a1 is greater than a3 go to positive int
slti a5,a1,1			# set a5  if a1 is less than 1 ( 0 or negative)
bnez a5,is0			# if a5 is not 0 branch to is0 (a1 = 0
la t0,result1			# if a5 is 1 ,a1 !- 0
call soft_mul			# multiplies a1(1st integer ) with 1000
la t0,result1			# point to to result1 (1st integer
la x10,result_lo_m		# point x10 to result_lo_m which has 1000*a1
lw x7,0(x10)			# copy multiplied value
sw x7,0(t0)			# store 1000*a1 in result1
is0:
la t0,result_lo			# point t0 to result_lo ( second integer)
call soft_mul			# multiply 1000 wih a3(2nd integer)
la t0,result_lo			# point to to result_lo
la x10,result_lo_m		# point x10 to result_lo_m holds value of 1000*a3
lw x7,0(x10)			# copy softmul value to x7
sw x7,0(t0)			# store in result_lo

la t0,result1			# point to to result1 , ist integer
lw a1,0(t0)			# copy result1 to a1
la t0,result_lo			# point t0 to result_lo ( second integer)
lw a3,0(t0)			# copy to a3
la t0,fraction			# point to to result_hi_m for fraction
lw a2,0(t0)			# store in a2

sub a3,a3,a2			# subtract fraction from 2nd integer * 1000 (a3*1000)
sub a3,a3,a1			# subtract 1st integer from a3, a3 now has integer part and fraction together (negative value)
li x6,0
div:
addi x6,x6,1			# increase counter ,counts how many 1000 in a3
addi a3,a3,-1000		# subtarct 1000 from a3
li x7,1000			# compare value 1000
bge a3,x7,div			# if a3 is greater or equal to 1000 branch to div
la t0,result1			#point to to result1
sw x6,0(t0)			# store x6 which has counts of 1000
la t0,fraction			# point to fraction
sw a3,0(t0)			# a3 has all 1000s extracted . now what remains is fraction
la t0,sign			# sign register  holds negative flag 1
li x7,1				# load x7 with 1
sw x7,0(t0)			# store 1 in sign register to indicate result negative.
J exit_subtraction


positive_frac:
sub a2,a2,a4		# difference in a2
la t0,result_hi_m
sw a2,0(t0)
j checkint

positiveint:
sub a1,a1,a3
la t0,result_lo_m
sw a1,0(t0)


exit_subtraction:
	ret




soft_mul:
	addi sp,sp,-24
	sw ra,0(sp)
	sw a1,4(sp)
	sw a2,8(sp)
	sw a3,12(sp)
	sw a4,16(sp)
	sw a5,20(sp)

	#li a1,0xffffffff 	# multiplicand
	lw a1,0(t0)
 	li a2,1000		# multiplier
 	li a3,0x00000000 	# result_lo
 	li a4,0x00000000 	# result_hi
	li a5,0			# working register 
 
 
 start:
 	call ROR		# rotate right multiplier to test lsb is 0 or 1
 	bnez x3,multiply	# if lsb =1 branch to repeated adding of multiplicant to result register
 finishmul:
 	call RLL2		# shift multiplicand left or multiply by 2
 	beqz a2,exit_proc
 	J start			# repeat loop
 exit_proc:
 	#j exit_proc
	la t0,result_lo_m
	sw a3,0(t0)
	la t0,result_hi_m
	sw a4,0(t0)
	lw a5,20(sp)
	lw a4,16(sp)
	lw a3,12(sp)
	lw a2,8(sp)
	lw a1,4(sp)
	lw ra,0(sp)
 	ret
 multiply:
 	add a5,a3,a1		# add multiplicant to low result register and store final result in a5 for processing
 	sltu a0 a5,a3		# set a0 to 1 if result of addition a3:a1 i a5 is greater than a3
 	sltu x3,a5,a1		# set x3 to 1 if result of addition a3:a1 in a5 is greater than a1
 	or a0,a0,x3		# or a0 and x3 , if 1 carry if a0 = 0 no carry
 	bnez a0,carryset	# if a0 = 1 carry set, branch to label carry set
 	mv a3,a5		# result in working register copied to a3 low result register
 	J finishmul		# jump to label finishmul
 carryset:			# reach here only if carryset
 	mv a3,a5		# copy a5 to low result a3
 	addi a4,a4,1		# add carry to a4 high register result
 	J finishmul		# jump to label finishmul
 
 ROR:
 	li x3,0			# clear carry
 	mv t0,a2		# copy number in a2 to t0
 	andi t0,t0,1		# extract lsb is 0 or 1
 	beqz t0,zzz		# if lab is 0 branch to zzz
 		li x3,1		# if lsb is 1 carry occured , load 1 in carry register x3
 	srli a2,a2,1		# shift right a2 by 1 postion 
 	ret			# return to caller
 zzz:				# reach here if lsb =0
 	li x3,0			# load x3 0 indicating carry bit is 0
 	srli a2,a2,1		# right shift multiplier once. divide multiplier by 2
 	ret			# return to caller
 
 ROL:
 	li x3,0			# 
 	mv t0,a2
 	li x3,0x80000000
 	and t0,t0,x3
 	beqz t0,zzz1
 	li x3,1			# carry
 	slli a2,a2,1
 	ret
 zzz1:
 	li x3,0
 	slli a2,a2,1
 	ret
 
 RLL2:				# rotate left 2 registers a3:a5
 	mv a5,a4		# copy contents of a4 to a5
 	li x3,0			# clear x3
 	mv t0,a1		# copy multiplicant to t0
 	li x3 ,0x80000000	# load x3 MSB bitmask
 	and t0,t0,x3		# and with 0x800000000 to extract the MSB
 	bnez t0,OR1		# if MSB = 1 branch to OR1 label
 	slli a1,a1,1		# shift left 1 position a1 register ( multiplicant)
 	slli a5,a5,1		# shift left 1 position working register with value of a4 register ( multiplicant)
 	beqz a2,exit		# if multiplier register is 0 exit
 	mv a4,a5		# copy back the shifter multiplicant to a4
 	ret
 OR1:
 	mv a5,a4
 	slli a1,a1,1
 	slli a5,a5,1
 	li x3,1
 	or a5,a5,x3
 	beqz a2,exit
 	mv a4,a5
 	ret
exit:
	ret

