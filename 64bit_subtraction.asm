.data
resultlow : .word 0
resulthigh: .word 0

.text
# 64bit numbers in a1:a0 and a3:a2

li a1,0xffffffff		# high x11
li a0,0xffffffff		# low  x10
li a3,0x0fffffff		# high x13
li a2,0xffffffff		# low  x12
li t0,1				# carry x5
RR1:
sub a0,a0,a2			# subtract a0:a2
bltz a0,underflow		# if underflow
sub a1,a1,a3			# subtract high registers
la t1,resultlow
sw a0,0(t1)
la t1,resulthigh
sw a1,0(t1)
ret
				# increase buffer address + 1
underflow:
sub a1,a1,a3			# subtract high registers
sub a1,a1,t0			# subtract with carry
la t1,resultlow
sw a0,0(t1)
la t1,resulthigh
sw a1,0(t1)
ret







