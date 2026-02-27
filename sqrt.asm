# https://leetcode.com/problems/sqrtx/
# Calculate floor(sqrt(x))

.data
x:        .word 150

.text
main:
        # call floor(squrt(x))
        lw  a0, x             # load argument x
        jal ra, floor_sqrt    # call floor_sqrt(x)
        
        # print result
        mv a0, a0             # integer to print
        li a7, 36             # print int environment call (1)
        ecall                 # print int environment call
        
        # exit
        li a7, 10             # exit environment call id (10)
        ecall                 # exit environment call
        
floor_sqrt:
        li   t0, 0            # unsigned int s = 0;
        li   t1, 1            # unsigned int i = 1;
        slli t1, t1, 15       # i = i << 15
for_next_bit:
        beqz t1, next_bit_end # if i == 0 goto next_bit_end
        add  t2, t0, t1       # t2 = s + i
        mul  t3, t2, t2       # t3 = (t2)^2 = (s+i)^2
        bltu a0, t3, if_x_is_less_than_t3 # if a0 < t3 then don't add
        add  t0, t0, t1       # s = s + i
if_x_is_less_than_t3:
        srli t1, t1, 1        # i = i >> 1
        j for_next_bit        # goto for_next_bit
next_bit_end:  
        mv a0, t0
        ret
