# Lab 4 Stretched Goal – Software Sinewave Generator
# Uses addi, bne, and lbu (Load Byte Unsigned from Data Memory LUT)
# Data Memory [0x00..0xFF] holds 256 8-bit unsigned sine samples.

main:
    addi t1, zero, 0x100    # t1 (x6)  = 256 (samples per sine period)
    addi a0, zero, 0x0      # a0 (x10) = 0   (output sample)
mloop:
    addi a1, zero, 0x0      # a1 (x11) = 0   (LUT address / phase index)
iloop:
    lbu  a0, 0(a1)          # a0 = DataMem[a1 + 0] (unsigned 8-bit sine sample)
    addi a1, a1, 1          # a1 = a1 + 1
    bne  a1, t1, iloop      # if a1 != 256, loop back to iloop (0x0c)
    bne  t1, zero, mloop    # always branch back to mloop (0x08)
