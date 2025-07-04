.data:
length: .word 0
.text:
	li a0,0x00
	la a2,length
	li t0,4			# length of string needed
	sw t0,0(a2)		# store in sram
convert_to_decimal:
    	addi sp, sp, -16
    	mv   gp, sp          	# t1 = start of buffer (store digits forward)
    	li   a2, 0		# character count

digit_loop:
    	call div_u10		# call division by 10
    	addi a1, a1, '0'	# add ascii 0 to remainder of above operation
    	sb   a1, 0(gp)        	# Store digit at address pointed by gp
    	addi gp, gp, 1        	# Move pointer right
    	addi a2, a2, 1        	# increase character count
    	bnez a0, digit_loop	# digit_loop is repeated till qoutient is 0

string_length:
	la a3,length		# point to length
	lw a3,0(a3)		# load contents to a3 itself( expected length)
test_length:
	bgeu a3,a2,add_space	# if required length is  greater than current length
	j here			# if conditions meet jump to label here
add_space:
	li a1,' '		# laod space
	sb a1,0(gp)		# store in sram to pad space to required length
	addi gp, gp, 1        	# Move pointer right
	addi a2, a2, 1        	# increase character count
	j test_length		# test again and increase if needed till count becomes equal
   

here:
	j here

# Register Usage:
# a0 = input number / quotient
# a1 = remainder
# t0 = bit counter (32)
# t1 = scratch
# t2 = divisor
	

# Input: a0 = number to divide (e.g., 100)
# Output: a0 = quotient (e.g., 10), a1 = remainder (e.g., 0)
div_u10:
    li    a1, 0           # Clear remainder
    li    t0, 32          # 32 bits to process
    mv    t1, a0          # t1 = working copy of input
    li    a0, 0           # a0 will store quotient

div_loop:
    # Build quotient in a0
    slli  a0, a0, 1       # Shift quotient left
    
    # Process next bit
    srli  t2, t1, 31      # Get MSB
    slli  t1, t1, 1       # Shift input left
    slli  a1, a1, 1       # Shift remainder left
    or    a1, a1, t2      # Insert new bit
    
    # Check if remainder >= 10
    li    t2, 10
    bltu  a1, t2, skip_sub
    
    # Adjust remainder and set quotient bit
    sub   a1, a1, t2
    ori   a0, a0, 1       # Set LSB of quotient
    
skip_sub:
    addi  t0, t0, -1
    bnez  t0, div_loop
    
    ret        # Result: a0=quotient, a1=remainder
