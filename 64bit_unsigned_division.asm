#works

.data
result_high: .word 0
result_low: .word 0
# a1 = nimber1
# a2 = number2
# a3 = workreg
# a4= low register = a4:a1
# a6 =hi register = a6:a2
# a5 carry

.text
li a4,0
li a6,0 
li a1, 0xffffffff
li a2, 0x1234
X:
sub a3,a1,a2
sltu a5,a1,a2
bnez a5,carry
#bltu a3, a0, carry
mv a1,a3
sub a3,a4,a6
addi a7,a7,1
J X
la t0, result_low
sw a7,0(t0)
nop
nop
ret
carry:
la t0, result_low
sw a7,0(t0)
#sub a4,a4,a5
#add a1,a1,a5
la t0, result_high
sw a1,0(t0)
nop
nop 
ret


