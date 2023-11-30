.data 
result_lo: .word 0
result_hi: .word 0
modulo:    .word 0



.text
 li a1,0xffffffff # low
 li a2,0x0fffffff # high
 li a3,0xffffffff # low
 li a4,0x00000000 # high
 add a5,a1,a3
 sltu t1,a5,a1
 sltu t0,a5,a3
 or t1,t1,t0
 bnez t1, carry
 mv a1,a5
 add a5,a2,a4
 mv a2,a5
 la t0,result_lo
 sw a1,0(t0)
 la t0, result_hi
 sw a2,0(t0)
 here:
 J here
 carry:
 mv a1,a5
 add a5,a2,a4
 add a5,a5,t1
 mv a2,a5
 la t0,result_lo
 sw a1,0(t0)
 la t0, result_hi
 sw a2,0(t0)
here1:
 J here1