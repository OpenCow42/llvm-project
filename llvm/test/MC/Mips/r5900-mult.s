# RUN: llvm-mc %s -triple=mips64el-none-elf -mcpu=r5900 \
# RUN:   -show-encoding | FileCheck %s --check-prefix=ENC
# RUN: llvm-mc %s -triple=mips64el-none-elf -mcpu=r5900 \
# RUN:   -filetype=obj -o %t
# RUN: llvm-objdump -d --mcpu=r5900 %t | FileCheck %s --check-prefix=DIS

# ENC: mult $2, $3, $4 # encoding: [0x18,0x10,0x64,0x00]
# ENC: multu $5, $6, $7 # encoding: [0x19,0x28,0xc7,0x00]

# DIS: mult $2, $3, $4
# DIS: multu $5, $6, $7

mult $2, $3, $4
multu $5, $6, $7
