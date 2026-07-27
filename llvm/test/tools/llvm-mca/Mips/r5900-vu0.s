# RUN: llvm-mca -mtriple=mips64el-scei-ps2 -mcpu=r5900 -mattr=+vu0 \
# RUN:   -instruction-info -iterations=1 %s | FileCheck %s

# The accumulator operations can issue on consecutive cycles. The final
# VMADDW writes a VF register with the qualified four-cycle result latency.
# LQC2 and SQC2 share the load/store resource with conservative throughput.

# CHECK: Iterations:        1
# CHECK: Instructions:      6
# CHECK: Total Cycles:      11
# CHECK: Dispatch Width:    1
# CHECK: Instruction Info:
# CHECK: [1]: #uOps
# CHECK: [2]: Latency
# CHECK: [3]: RThroughput
# CHECK:  1      2     2.00    *                   lqc2
# CHECK:  1      1     1.00                        vmulax.xyzw
# CHECK:  1      1     1.00                        vmadday.xyzw
# CHECK:  1      1     1.00                        vmaddaz.xyzw
# CHECK:  1      4     1.00                        vmaddw.xyzw
# CHECK:  1      1     1.00           *            sqc2

lqc2 $vf1, 0($4)
vmulax.xyzw $ACC, $vf2, $vf1
vmadday.xyzw $ACC, $vf3, $vf1
vmaddaz.xyzw $ACC, $vf4, $vf1
vmaddw.xyzw $vf5, $vf1, $vf1
sqc2 $vf5, 0($5)
