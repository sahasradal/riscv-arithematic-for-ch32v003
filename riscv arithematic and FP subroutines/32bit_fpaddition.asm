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

.text
#	li a1,100     	 	# number to be dividend
#	li a2,21		# divisor
#	li a3,0x01		# result & also used to count
#	li a4,0		 	# result hi register
#	li a5,0			# workig register/remainder
la t0,result1
li x7,10
sw x7,0(t0)
la t0,fraction
li x7,500
sw x7,0(t0)
la t0,result_lo
li x7,10
sw x7,0(t0)
la t0,fraction2
li x7,501
sw x7,0(t0)


la t0,result1
lw a1,0(t0)
la t0,fraction
lw a2,0(t0)
la t0,result_lo
lw a3,0(t0)
la t0,fraction2
lw a4,0(t0)
add a1,a1,a3			# integers added and stored in a1
add a2,a2,a4			# fractions added and stored in a2
li x7,1000
bgeu a2,x7,fcarry_set
la t0,result1
sw a1,0(t0)
la t0,fraction
sw a2,0(t0)
j exit_proc1
fcarry_set:
addi a1,a1,1
sub a2,a2,x7
la t0,result1
sw a1,0(t0)
la t0,fraction
sw a2,0(t0)
exit_proc1:
ret
