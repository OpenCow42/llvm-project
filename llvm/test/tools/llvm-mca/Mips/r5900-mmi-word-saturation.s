# RUN: llvm-mca -mtriple=mips64el-none-elf -mcpu=r5900 -mattr=+mmi \
# RUN:   -instruction-info -iterations=1 %s | FileCheck %s

# The final two instructions form a one-cycle-latency dependency chain through
# $10. Throughput remains conservatively single issue until the complete R5900
# machine model is qualified.

# CHECK: Iterations:        1
# CHECK: Instructions:      4
# CHECK: Dispatch Width:    1
# CHECK: Instruction Info:
# CHECK: [1]: #uOps
# CHECK: [2]: Latency
# CHECK: [3]: RThroughput
# CHECK:  1      1     1.00                  paddsw
# CHECK:  1      1     1.00                  padduw
# CHECK:  1      1     1.00                  psubsw
# CHECK:  1      1     1.00                  psubuw

paddsw $8, $2, $3
padduw $9, $4, $5
psubsw $10, $6, $7
psubuw $11, $10, $2
