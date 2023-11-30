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


#	li t2,0xffffffff
#	li a5,8
#	mv a3,t2
#	li a0,'0'
#	call print_char
#	li a0,'x'
#	call print_char
#bin_to_ascii:
	
#	andi a3,a3,0x0f
#	slti a4,a3,10			# set a4 to 1 if a3 is less than 10 ,10and higher a4=0
#	beqz a4 ,letter1
#	ori a3,a3,0x30
#	mv a0,a3
#	call print_char
#	srli,t2,t2,4
#	addi a5,a5,-1
#	mv a3,t2
#	j low_nibble
#letter1:
#	addi a3,a3,0x37
#	mv a0,a3
#	call print_char
#	srli,t2,t2,4
#	addi a5,a5,-1
#	mv a3,t2
#low_nibble:
#	bnez a5,bin_to_ascii
#	nop

#exit_bin_to_ascii:
#	j exit_bin_to_ascii




	li t2,0xdeadbeef		# load t2 with test value 0xdeadbeef
	li a5,8				# load a5 with count 8 , we convert a 32 bit register which is 8 nibbles
	la a1,buffer			# load address of buffer in a1
	addi a1,a1,7			# shift buffer address pointer 8 bytes ahead and store backwars as conversion is done from RHS to LHS
	mv a3,t2			# copy test value in t2 to a3
	li a0,'0'			# load a0 with ascii 0 (to print 0x)
	call print_char			# print 0
	li a0,'x'			# load a0 with ascii x (to print 0x)
	call print_char			# print x
bin_to_ascii:
	andi a3,a3,0x0f			# and test value in a3 with 0x0f , leaves only bit0-bit4 unaffected,low nibble
	slti a4,a3,10			# set a4 to 1 if a3 is less than 10 ,10and higher a4=0
	beqz a4 ,letter1		# if a4 is 0 ,a3 is greater than 9, so branch to process A to F at label "letter1"
	ori a3,a3,0x30			# or a3 with 0x30(ascii 0)to convert value to ascii number between 1-9
	mv a0,a3			# copy ascii in a3 to a0
	sb a0,0(a1)			# store byte in space pointed by a1 pointer, we store backwarsd else string will be printed in reverse
	addi a1,a1,-1			# reduce pointer address
	#call print_char
	srli,t2,t2,4			# shift test value right by 4 bits to discard the lower nibble just converted
	addi a5,a5,-1			# reduce the a5 nibble count register
	mv a3,t2			# copy newly shifted value in t2 to a3
	j testcount			# jump to testcount label(checks all 8 nibbles are converted)
letter1:
	addi a3,a3,0x37			# reach here if value in a3 greater or equal to 10(A-F)	, add 0x37("A")		
	mv a0,a3			# move to a0 ascii value in a3
	sb a0,0(a1)			# store byte in space pointed by a1 pointer, we store backwarsd else string will be printed in reverse
	addi a1,a1,-1			# reduce pointer address
	#call print_char
	srli,t2,t2,4			# shift test value right by 4 bits to discard the lower nibble just converted
	addi a5,a5,-1			# copy newly shifted value in t2 to a3
	mv a3,t2			# copy newly shifted value in t2 to a3
testcount:
	bnez a5,bin_to_ascii		# if a5 count not 0 branch to bin_to_ascii label
	li a5,8				# if all bits are converted reload a5 to 8 counts for printing
	la a1,buffer			# load address of buffer from which bytes will be loaded
Ploop:
	lb a0,0(a1)			# load a0 byte from buffer
	call print_char			# ecall to print char on console
	addi a1,a1,1			# increase buffer pointer
	addi a5,a5,-1			# decrease count
	bnez a5,Ploop			# loop till counter is 0
	
exit_bin_to_ascii:
	j exit_bin_to_ascii


	
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




