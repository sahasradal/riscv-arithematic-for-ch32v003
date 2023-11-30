works fine on RARS , 32x32 = 64bit

.data 
result_lo: .word 0
result_hi: .word 0
modulo:    .word 0



.text
 li a1,0xffffffff 		# multiplicant
 li a2,0x0000000f		# multiplier
 li a3,0x00000000 	# result_lo
 li a4,0x00000000 	# result_hi
 li a5,0		# working register 
 
 
 start:
 call ROR		# rotate right multiplier to test lsb is 0 or 1
 bnez x3,multiply	# if lsb =1 branch to repeated adding of multiplicant to result register
 finishmul:
 call RLL2		# shift multiplicand left or multiply by 2
 beqz a2,exit_proc
 J start		# repeat loop
 exit_proc:
 	j exit_proc
 	#ret
 multiply:
 add a5,a3,a1		# add multiplicant to low result register and store final result in a5 for processing
 sltu a0 a5,a3		# set a0 to 1 if result of addition a3:a1 i a5 is greater than a3
 sltu x3,a5,a1		# set x3 to 1 if result of addition a3:a1 in a5 is greater than a1
 or a0,a0,x3		# or a0 and x3 , if 1 carry if a0 = 0 no carry
 bnez a0,carryset	# if a0 = 1 carry set, branch to label carry set
 mv a3,a5		# result in working register copied to a3 low result register
 J finishmul		# jump to label finishmul
 carryset:		# reach here only if carryset
 mv a3,a5		# copy a5 to low result a3
 addi a4,a4,1		# add carry to a4 high register result
 J finishmul		# jump to label finishmul
 
 
 
 ROR:
 li x3,0		# clear carry
 mv t0,a2		# copy number in a2 to t0
 andi t0,t0,1		# extract lsb is 0 or 1
 beqz t0,zzz		# if lab is 0 branch to zzz
 li x3,1		# if lsb is 1 carry occured , load 1 in carry register x3
 srli a2,a2,1		# shift right a2 by 1 postion 
 ret			# return to caller
 zzz:			# reach here if lsb =0
 li x3,0		# load x3 0 indicating carry bit is 0
 srli a2,a2,1		# right shift multiplier once. divide multiplier by 2
 ret			# return to caller
 
 ROL:
 li x3,0		# 
 mv t0,a2
 li x3,0x80000000
 and t0,t0,x3
 beqz t0,zzz1
 li x3,1		# carry
 slli a2,a2,1
  ret
 zzz1:
 li x3,0
 slli a2,a2,1
 ret
 
 RLL2:			# rotate left 2 registers a3:a5
 mv a5,a4		# copy contents of a4 to a5
 li x3,0		# clear x3
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