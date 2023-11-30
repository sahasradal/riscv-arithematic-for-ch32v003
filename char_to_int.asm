.data
prompt: .asciz "Enter a string: "
errormessage: .asciz "ERROR\n\r "
buffer: .asciz "11\n"
.align 2
buffer1: .word 0

.text

main:
ASCII:
	li t6,0				# t6 counter for buffer1 stored number of bytes/next free byte space
	la t0,buffer			# t0 address place holder for buffer
	la t4,buffer1			# t4 address place holder for buffer1
	call ascii_to_bin		# subroutine converts ascii bytes into integers and stores in buffer1
	call bin_to_number		# subroutine reads buffer1 byte by byte and converts it to binary and stores in buffer1
end:
	j end				# end of program
	
ascii_to_bin:
	lb a0,0(t0)			# load byte from buffer pointed by 0 offset of t0
	li a1,'\n'			# load newline character '\n' in a1, newline once user hits enter button
	beq a0,a1,IG1			# check whether byte in a0 is '\n', if same branch to label IG1
ig1:
#	li a1,' '
#	beq a0,a1,IG2
ig2:
	li a1,0x30			# load a1 with 0x30(zero in ascii)
	blt a0,a1,notnum		# if byte in a0 is less than 0x30 ,byte not a number, branch to label notnum
	li a1 0x39			# load a1 with 0x39(nine in ascii), 
	bgt a0,a1,gthan9		# if byte in a0 greater than 9 ,branch to gthan9 label to check between A or F hex
	addi a0,a0,-0x30		# if between 0x30 and 0x39 , subtract 0x30 from byte to get integer value 
	mv t3,a0			# copy integer value now in a0 to t3
	sb t3,0(t4)			# store the integer byte to buffer1 pointed by t4
	addi t4,t4,1			# increase buffer1 address pointer by 1 byte
	addi t0,t0,1			# increase buffer pointer address by 1 byte
	addi t6,t6,1			# increase buffer 1 byte size counter by 1
	j ascii_to_bin			# repeat the process till a "\n' character is encountered in the buffer
notnum:
	la  a0, errormessage		# load address of errormessage in a0
	call print_string		# make an ECALL to print message "ERROR"
	j end				# terminate program as value stored in buffer is not a number
gthan9:
	li a1,0x61			# load a1 with 0x61 (a in ascii)
	blt a0,a1,notnum		# check a0 is less than 0x61, if less branch to notnum label
	li a1 0x66			# load a1 with 0x66 (f in ascii)
	bgt a0,a1,notnum		# check a0 is greater than 0x66, if greater branch to notnum label
	addi a0,a0,-0x57		# if between a and f (0x61 and 0x66) subtract 0x57 from byte to get the integer 10-15
	mv t3,a0			# copy integer value now in a0 to t3
	sb t3,0(t4)			# store the integer byte to buffer1 pointed by t4
	addi t4,t4,1			# increase buffer1 address pointer by 1 byte
	addi t0,t0,1			# increase buffer pointer address by 1 byte
	addi t6,t6,1			# increase buffer 1 byte size counter by 1
	j ascii_to_bin			# repeat the process till a "\n' character is encountered in the buffer
IG1:
	and a0,a0,x0			# clear a0 to 0
	addi t0,t0,1			# increase pointer
	ret				# return to caller
IG2:
	j ig2
	addi t0,t0,1
	ret	
	
	
bin_to_number:
	la t0,buffer1		# laod address of buffer1 in t0
	add t0,t0,t6		# add offset in t6 to buffer address in t0, t6 has last address + 1 which was increased by ascii_to_bin proc
	li t2,1			# load t2 with 1 , t2 holds the multiplier for digit position (1,10,100,1000....)
convert:
	addi,t0,t0,-1		# as buffer1 address pointer now points next free space we reduce 1 to get the last occupied address
	addi,t6,t6,-1		# subtract 1 from counter t6 till 0 to control how many bytes are converted
	lb t4,0(t0)		# load 1 byte from address pointed by pointer t0
	mul t4,t4,t2		# multiply the byte with multiplier in t2
	li t1,10		# load 10 in t1 (this is the factor by which we will increase the multiplier, decimal system increases by the order of 10)
	mul t2,t2,t1		# multiply the previous multiplier with 10 for the next decimal position
	add t5,t5,t4		# add the multiplied previous byte to t5 accumulator
	bnez t6,convert		# If t6 counter has not reached 0 loop back to label convert
	sw t5,0(t0)		# if t6 counter t6 has reached 0 store accumulated value in t5 to buffer1, value is binary equalent of input ascii
	nop
	ret	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
Print_integer:
		addi a7, x0, 1		
		add  a0, x0, t0
		ecall	
		jr ra, 0
Print_space:
		addi    x17, x0, 4      # environment call code for print_string
		li      a0, ' '		#space_str 	# pseudo-instruction: address of string
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




