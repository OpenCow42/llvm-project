# RUN: llvm-mc %s -triple=mips64el-none-elf -mcpu=r5900 -mattr=+mmi \
# RUN:   -show-encoding | FileCheck %s --check-prefix=ENC
# RUN: llvm-mc %s -triple=mips64el-none-elf -mcpu=r5900 -mattr=+mmi \
# RUN:   -filetype=obj -o %t
# RUN: llvm-objdump -d --mattr=+mmi %t | FileCheck %s --check-prefix=DIS
# RUN: not llvm-mc %s -triple=mips64el-none-elf -mcpu=r5900 \
# RUN:   -filetype=obj -o /dev/null 2>&1 | FileCheck %s --check-prefix=NO-MMI

# ENC: paddsw $2, $3, $4 # encoding: [0x08,0x14,0x64,0x70]
# ENC: padduw $2, $3, $4 # encoding: [0x28,0x14,0x64,0x70]
# ENC: psubsw $2, $3, $4 # encoding: [0x48,0x14,0x64,0x70]
# ENC: psubuw $2, $3, $4 # encoding: [0x68,0x14,0x64,0x70]

# DIS: paddsw $2, $3, $4
# DIS: padduw $2, $3, $4
# DIS: psubsw $2, $3, $4
# DIS: psubuw $2, $3, $4

# NO-MMI-COUNT-4: error: instruction requires a CPU feature not currently enabled

paddsw $2, $3, $4
padduw $2, $3, $4
psubsw $2, $3, $4
psubuw $2, $3, $4
