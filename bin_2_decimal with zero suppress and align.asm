.data
	line_str:     .asciz "-------------------------------\n"
	nline_str:    .asciz "\n-------------------------------\n"
	space_str:    .asciz " "
	delete:       .asciz "node deleted\n"
	append:       .asciz "node appended\n"
	tail: .word 1
	head: .word 1
	temp: .word 1
	decimal_buffer0:.word 0
	decimal_buffer1:.word 0
		.word 0
		
		
.text		
		

		
		
		la t3,decimal_buffer0
		
		li a0,52354		# number to be converted 
		li a1,1000000000
bin_to_decimal:
		mv t1,a0
		li t0,1000000000
		divu t2,t1,t0
		bgez t2,div1
E1:
		li t0,100000000
		divu t2,t1,t0
		bgez t2,div2
E2:
		li t0,10000000
		divu t2,t1,t0
		bgez t2,div3
E3:
		li t0,1000000
		divu t2,t1,t0
		bgez t2,div4
E4:
		li t0,100000
		divu t2,t1,t0
		bgez t2,div5
E5:
		li t0,10000
		divu t2,t1,t0
		bgez t2,div6
E6:
		li t0,1000
		divu t2,t1,t0
		bgez t2,div7
E7:
		li t0,100
		divu t2,t1,t0
		bgez t2,div8
E8:
		li t0,10
		divu t2,t1,t0
		bgez t2,div9
E9:
		bgez t2,div10



div1:		
		addi t2,t2,0x30
		sb t2,0(t3)
		addi t3,t3,1
		remu t2,t1,t0
		mv t1,t2
		j E1	
div2:
		addi t2,t2,0x30
		sb t2,0(t3)
		addi t3,t3,1
		remu t2,t1,t0
		mv t1,t2
		j E2
div3:
		addi t2,t2,0x30
		sb t2,0(t3)
		addi t3,t3,1
		remu t2,t1,t0
		mv t1,t2
		j E3
div4:
		addi t2,t2,0x30
		sb t2,0(t3)
		addi t3,t3,1
		remu t2,t1,t0
		mv t1,t2
		j E4
div5:
		addi t2,t2,0x30
		sb t2,0(t3)
		addi t3,t3,1
		remu t2,t1,t0
		mv t1,t2
		j E5	
div6:
		addi t2,t2,0x30
		sb t2,0(t3)
		addi t3,t3,1
		remu t2,t1,t0
		mv t1,t2
		j E6	
div7:		
		addi t2,t2,0x30
		sb t2,0(t3)
		addi t3,t3,1
		remu t2,t1,t0
		mv t1,t2
		j E7	
div8:		
		addi t2,t2,0x30
		sb t2,0(t3)
		addi t3,t3,1
		remu t2,t1,t0
		mv t1,t2
		j E8	
div9:																		
		addi t2,t2,0x30
		sb t2,0(t3)
		addi t3,t3,1
		remu t2,t1,t0
		mv t1,t2
		j E9	
div10:		
		addi t2,t1,0x30
		sb t2,0(t3)	

#########################################################################################################
		call supress_lead0	# subroutine suppresses  leading zeros in the result (good for LCD)	
		call ror3		# subroutine that rotates 3 registers right ( for left aligning result on screen)

##########################################################################################################
print:
		la s0,decimal_buffer0	# load address of sram decimal_buffer0 (result stored)
		li t4,10		# load t4 number of chars to be printed from sram
printloop:
		lb t0,0(s0)		# load 1 byte from decimal_buffer0
		add  a0, x0, t0		# move data to a0
		call print_char		# sys call of RARS , implement uart for hardware
		addi s0,s0,1		# increase address pointer
		addi t4,t4,-1		# decrease word/char count
		beqz t4,exit2		# if char count equal 0 go to exit
		j printloop		# if char count not 0 , loop to printloop label
exit2:
		# Print a new line string
		addi    x17, x0, 4      # environment call code for print_string
		la      a0, nline_str 	# pseudo-instruction: address of string
		ecall 
here:
		j here	

############################################################################################################
# subrutine to suppress leading zeros in decimal calculation, stores 0x20 in all leading 0x30 positions
############################################################################################################
supress_lead0:
		la s0,decimal_buffer0	# load s0 with address of decimal_buffer0
		li t4,9			# we have 10 bytes but 0 supress is done upto unit position only
		li t6,0x30		# hex ASCII 0 , t7 used as comparison register
check_loop:
		lb t0,0(s0)		# load the msb 
		beq t0,t6,addspace	# is t0 0x30/0,if yes branch to addspace label to store a blank space
cl:
		addi s0,s0,1		# increase address pointer
		addi t4,t4,-1		# reduce byte count
		beqz t4,exit3		# if 0 exit
		bne t0,t6,exit3	# if t0 not equal to 0 exit
		j check_loop		# loop
exit3:
		jr ra, 0		# ret
	
addspace:
		li a0,' '		# load a0 with 0x20 ascii for space
		sb a0,0(s0)		# store space in decimal_buffer0 pointed by pointer
		j cl			# jump back to label cl
					
#######################################################################################

ror3:
		la t0,decimal_buffer0		# load address of decimal_buffer0
		lw a0,8(t0)     		# lsb
		lw a1,4(t0)			# msb
		lw a5,0(t0)			# msb
		li t3,40		        # number of shifts , each nibble needs 4 shifts, byte 8 shifts
		li a2,0x00000001		# top bit mask, to isolate lsb and check its 1 or 0
		li a3,0x7fffffff		# zero mask , used to and in a 0 in msb during ror
		li a4,0x80000000		# 1 mask, used to or a 1 in the msb during a ROR
rxx3:
		
		mv t1,a0			# move value to t1
		srli a0,a0,1			# left shift once
		and t1,t1,a2			# and t1 with topbit mask,1 or 0
		beqz t1,zero1			# if 0 in t1 branch to label zero1
		mv t1,a1			# copy the mid register a1,
		srli a1,a1,1			# left shift once
		or a1,a1,a4			# else OR 1 to msb register
rxx2:
		and t1,t1,a2			# this step isolates lsb of a1 to 0 or 1
		beqz t1,zero2			# if 0 branch to zero2 label
		srli a5,a5,1			# shift logical right a5
		or a5,a5,a4			# add by oring the lsb with 1 in a4
		addi t3,t3,-1			# decrease the shift count
		beqz t3,exit_ror3		# if count register is 0 , branch to label "ëxit_ror3"
		j rxx3				# start again
zero1:						# reach here if a0 lsb bit was 0
		mv t1,a1			# copy ai to t1 before shift
		srli a1,a1,1			# shift logical right a1
		and a1,a1,a3			# insert a 0 in the msb
		j rxx2				# jump to label rxx2

zero2:						# reach here if a1 lsb was 0
		srli a5,a5,1			# shift logical right 1 shift a5 register
		and a5,a5,a3			# make msb 0 of a5 register
		addi t3,t3,-1			# decrease shift count 
		beqz t3,exit_ror3		# if shift count register reaches 0 branch to label "exit_ror3"
		j rxx3				# jump to label rxx2
exit_ror3:
		sw a5,0(t0)			# store contents of a5 to SRAM
		sw a1,4(t0)			# store contents of a1 to SRAM
		sw a0,8(t0)			# store contents of a0 to SRAM
		jr ra, 0			# ret



###############################################################################################################
								
																								
																											
																														
																																	
																																							
					
Print_integer:
		addi a7, x0, 1		
		add  a0, x0, t0
		ecall	
		jr ra, 0
Print_space:
		addi    x17, x0, 4      # environment call code for print_string
		la      a0, space_str 	# pseudo-instruction: address of string
		ecall 
		jr ra, 0
read_int:
		addi a7, x0, 5		# a7 (x17) = syscall number 5 read int
		ecall
		jr ra, 0		# return value is already in a0

read_char:	#a0 has the char read from console
		li a7, 12
		ecall	
		jr ra, 0

read_string:	#la a0,inputbuffer
		li a7, 93
		ecall 
		jr ra, 0

print_char:	#addi a0,x0,"d"
		li a7, 11
		ecall
		jr ra, 0

print_string:	#la  a0, nline_str , address of string in a0	
		addi    x17, x0, 4      # environment call code for print_string
		ecall 
		jr ra, 0

node_alloc:
		addi a7, x0, 9		# a7 (x17) = syscall number 9 "Sbrk" set break - allocate heap memory to x17 (a7) register
		addi a0, x0, 4		# a0 (x10) = amount of memory in bytes	- output: address of memory saved at a0
		ecall
		jr ra, 0		# return value is already in a0








# Make room to save stuff
	addi sp, sp, -36
	sw s0, 4(sp)
	sw s1, 8(sp)
	sw s2, 12(sp)
	sw s3, 16(sp)
	sw s4, 20(sp)
	sw s5, 24(sp)
	sw s6, 28(sp)
	sw s7, 32(sp)
	sw ra, 36(sp)
# Restore saved state 
	lw s0, 4(sp)
	lw s1, 8(sp)
	lw s2, 12(sp)
	lw s3, 16(sp)
	lw s4, 20(sp)
	lw s5, 24(sp)
	lw s6, 28(sp)
	lw s7, 32(sp)
	lw ra, 36(sp)
	addi sp, sp, 36

printHex:
        # convert t0 to digits in the buffer
        la a1, temp
        li t2, 10
hexLoop:
        andi t3, a0, 0xF
        srli a0, a0, 4 
	blt t3, t2, offset
	addi t3, t3, 7 # += 'A' - '0' - 10; preps a numerical 10-15 to be converted to the characters 'A'-'F'
offset:	
        addi t3, t3, 0x30 # += '0'; converts a numerical 0-9 to the characters '0'-'9'
        addi a1, a1, -1
	sb t3, 0(a1)
        bnez a0, hexLoop

	# Add the 0x to the funct	
	addi a1, a1, -2
	li t0, 0x78 # x
	sb t0, 1(a1) 
	li t0, 0x30 # 0
	sb t0, 0(a1)

	# Write (64) from the temporary buffer to stdout (1) 
	li a0, 1
	la a2, temp
	sub a2, a2, a1
	li a7, 64
	ecall
	ret
