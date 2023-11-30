.data
	line_str:     .asciz "-------------------------------\n"
	nline_str:    .asciz "\n-------------------------------\n"
	space_str:    .asciz " "
	delete:       .asciz "node deleted\n"
	append:       .asciz "node appended\n"
	tail: .word 1
	head: .word 1
	temp: .word 1
	buffer:.word 0
		.word 0
		.word 0
		.word 0
		.word 0
		.word 0
		.word 0
		.word 0
		.word 0
		.word 0
		.word 0
		.word 0
		.word 0
		.word 0
		.word 0
		.word 0
		.word 0
		.word 0
		.word 0
		.word 0
		.word 0
		.word 0
		.word 0
		.word 0
		.word 0
		.word 0
		.word 0
		.word 0
		.word 0
		.word 0
		.word 0
		
.text		
		

		
		
		
		
		la t3,buffer
		
		li a0,52354
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
		sw t2,0(t3)
		addi t3,t3,4
		remu t2,t1,t0
		mv t1,t2
		j E1	
div2:
		addi t2,t2,0x30
		sw t2,0(t3)
		addi t3,t3,4
		remu t2,t1,t0
		mv t1,t2
		j E2
div3:
		addi t2,t2,0x30
		sw t2,0(t3)
		addi t3,t3,4
		remu t2,t1,t0
		mv t1,t2
		j E3
div4:
		addi t2,t2,0x30
		sw t2,0(t3)
		addi t3,t3,4
		remu t2,t1,t0
		mv t1,t2
		j E4
div5:
		addi t2,t2,0x30
		sw t2,0(t3)
		addi t3,t3,4
		remu t2,t1,t0
		mv t1,t2
		j E5	
div6:
		addi t2,t2,0x30
		sw t2,0(t3)
		addi t3,t3,4
		remu t2,t1,t0
		mv t1,t2
		j E6	
div7:		
		addi t2,t2,0x30
		sw t2,0(t3)
		addi t3,t3,4
		remu t2,t1,t0
		mv t1,t2
		j E7	
div8:		
		addi t2,t2,0x30
		sw t2,0(t3)
		addi t3,t3,4
		remu t2,t1,t0
		mv t1,t2
		j E8	
div9:																		
		addi t2,t2,0x30
		sw t2,0(t3)
		addi t3,t3,4
		remu t2,t1,t0
		mv t1,t2
		j E9	
div10:		
		addi t2,t1,0x30
		sw t2,0(t3)	


print:
		la s0,buffer
		li t4,10
printloop:
		lb t0,0(s0)
		add  a0, x0, t0
		call print_char
		addi s0,s0,4
		addi t4,t4,-1
		beqz t4,exit2
		j printloop
exit2:
				
		# Print a new line string
		addi    x17, x0, 4      # environment call code for print_string
		la      a0, nline_str 	# pseudo-instruction: address of string
		ecall 
here:
		j here		
			
					
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
