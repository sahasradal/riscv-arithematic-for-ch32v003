#t2 has qoutient and a1 has remainder, works better for small numbers heavy on clock cycle for large number
# for CH32V003


.data
result_high: .word 0
result_low: .word 0
# a1 = nimber1 # low
# a2 = number2 # high
# a5 = workreg
# a3= low register = a2:a1
# a4 =hi register = a4:a3
# t1 carry

.text
li a2,0
li a4,0 
li a1, 1000
li a3, 33
X:
sub a5,a1,a3
sltu t1,a1,a3
bnez t1,carry
#bltu a3, a0, carry
mv a1,a5
sub a5,a2,a4
addi t2,t2,1
J X
#la t0, result_low
#sw t2,0(t0)
#nop
#nop
#ret
carry:
la t0, result_low
sw t2,0(t0)
#sub a4,a4,a5
#add a1,a1,a5
la t0, result_high
sw a1,0(t0)		# remainder in a1
nop
nop 
ret
