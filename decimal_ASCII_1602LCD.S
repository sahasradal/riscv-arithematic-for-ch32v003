decimal to ASCII converter for 1602_LCD , gives signed output on the screen, need 3 word in sram with name mem

. data
result_lo: .word 0
mem: .word 0




.text
la a0,result_lo
li x7,0x12345678
sw x7,0(a0)
call convert_to_decimal_signed
here:
J here

#######################################################################################
# ────────────────────────────────────────────────────────────────
# signed version deimal to ASCII converter for 1602 LCD , "call convert_to_decimal_signed"
# Input:  value in result_lo (treated as unsigned)
# Output: ASCII digits stored backwards in mem (as before)
# ────────────────────────────────────────────────────────────────
convert_to_decimal_unsigned:
    addi sp, sp, -24
    sw ra,  0(sp)
    sw a0,  4(sp)
    sw gp,  8(sp)
    sw tp, 12(sp)
    sw t2, 16(sp)
    sw t0, 20(sp)

    la a0, result_lo
    lw a0, 0(a0)                # load unsigned value

    la gp, mem                  # result buffer
lb t0,0(gp)

li tp, 0x20202000           	# spaces   li tp, 0x20202020
or tp,tp,t0
    sw tp, 0(gp)
li tp, 0x20202020
    sw tp, 4(gp)
    sw tp, 8(gp)
    addi gp, gp, 9              # start from end (backwards)

digit_loop_u:
    call div_u10                # a0 = quot, tp = rem (0-9)
    addi tp, tp, '0'
    sb tp, 0(gp)
    addi gp, gp, -1
    addi t2, t2, 1
    bnez a0, digit_loop_u

    # Restore
    lw t0, 20(sp)
    lw t2, 16(sp)
    lw tp, 12(sp)
    lw gp,  8(sp)
    lw a0,  4(sp)
    lw ra,  0(sp)
    addi sp, sp, 24
    ret


# ────────────────────────────────────────────────────────────────
# Signed version – handles negative numbers
# Input:  value in result_lo (signed 32-bit)
# Output: ASCII digits in mem (with '-' if negative)
#         Calls the unsigned version internally after handling sign
# ────────────────────────────────────────────────────────────────
convert_to_decimal_signed:
    addi sp, sp, -24
    sw ra,  0(sp)
    sw a0,  4(sp)
    sw gp,  8(sp)
    sw tp, 12(sp)
    sw t2, 16(sp)
    sw s0, 20(sp)               # extra for sign handling

    la a0, result_lo
    lw s0, 0(a0)                # s0 = signed value

    bgez s0, no_sign            # positive or zero → no '-'

    # Negative number: store '-' and take absolute value
    li   a0, '-'
    la   gp, mem
    sb   a0, 0(gp)              # put '-' at beginning
    #addi gp, gp, 1              # move pointer after '-'
    neg  s0, s0                 # s0 = |value|

    # Store |value| back to result_lo so unsigned version can use it
    la   a0, result_lo
    sw   s0, 0(a0)
    j process
no_sign:
    li   a0, 0x20
    la   gp, mem
    sb   a0, 0(gp)
process:
    # Now call the unsigned converter (it will fill from mem+1 or mem)
    call convert_to_decimal_unsigned

    # If we had negative, we already put '-' at mem+0
    # Unsigned version wrote digits starting from mem+9 backwards
    # → result is correct ( '-' + digits or just digits )

    lw s0, 20(sp)
    lw t2, 16(sp)
    lw tp, 12(sp)
    lw gp,  8(sp)
    lw a0,  4(sp)
    lw ra,  0(sp)
    addi sp, sp, 24
    ret


# Your existing div_u10 remains unchanged (it's already good)
div_u10:
    addi sp,sp,-20
    sw ra,0(sp)
    sw a1,4(sp)
    sw t0,8(sp)
    sw gp,12(sp)
    sw t2,16(sp)
    li    a1, 0           # Clear remainder
    li    t0, 32          # 32 bits
    mv    gp, a0          # working copy
    li    a0, 0           # quotient
div_loop:
    slli  a0, a0, 1
    srli  t2, gp, 31
    slli  gp, gp, 1
    slli  a1, a1, 1
    or    a1, a1, t2
    li    t2, 10
    bltu  a1, t2, skip_sub
    sub   a1, a1, t2
    ori   a0, a0, 1
skip_sub:
    addi  t0, t0, -1
    bnez  t0, div_loop
    mv    tp,a1           # remainder to tp
    lw t2,16(sp)
    lw gp,12(sp)
    lw t0,8(sp)
    lw a1,4(sp)
    lw ra,0(sp)
    addi sp,sp,20
    ret
