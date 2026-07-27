# RUN: llvm-mca -mtriple=mips64el-scei-ps2 \
# RUN:   -mcpu=r5900-scalar-experimental -instruction-info -iterations=1 %s \
# RUN:   | FileCheck %s

# This checks the candidate model, not hardware-qualified performance. The
# default r5900 CPU intentionally remains on the conservative issue-width-one
# model until physical-console dependent/independent chain measurements pass.

# CHECK: Iterations:        1
# CHECK: Instructions:      10
# CHECK: Dispatch Width:    2
# CHECK: Instruction Info:
# CHECK: [1]: #uOps
# CHECK: [2]: Latency
# CHECK: [3]: RThroughput
# CHECK:  1      1     0.50                  addu
# CHECK:  1      1     0.50                  sll
# CHECK:  1      1     1.00    *             lw
# CHECK:  1      1     1.00           *      sw
# CHECK:  1      4     2.00                  mult
# CHECK:  1      1     0.50                  mflo
# CHECK:  1      4     1.00                  add.s
# CHECK:  1      8     7.00                  div.s
# CHECK:  1      1     1.00                  bnez
# CHECK:  1      1     0.50                  nop

.set noreorder

addu $2, $3, $4
sll $5, $6, 3
lw $7, 0($8)
sw $7, 4($8)
mult $9, $10
mflo $11
add.s $f0, $f1, $f2
div.s $f3, $f4, $f5
bnez $2, 1f
nop
1:
