# RUN: llvm-mca -mtriple=mips64el-scei-ps2 -mcpu=r5900 \
# RUN:   -instruction-info -iterations=1 %s | FileCheck %s

# Historical R5900 documentation and the reference backend describe a
# four-cycle result latency with one multiply accepted every two cycles.
# Physical-console qualification remains required before this provisional
# timing is expanded into a complete scalar scheduling model.

# CHECK: Iterations:        1
# CHECK: Instructions:      2
# CHECK: Dispatch Width:    1
# CHECK: Instruction Info:
# CHECK: [1]: #uOps
# CHECK: [2]: Latency
# CHECK: [3]: RThroughput
# CHECK:  1      4     2.00                  mult
# CHECK:  1      4     2.00 {{.*}} multu

mult $2, $3, $4
multu $5, $6, $7
