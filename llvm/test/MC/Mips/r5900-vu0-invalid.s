# RUN: not llvm-mc %s -triple=mips64el-scei-ps2 -mcpu=r5900 -mattr=+vu0 2>&1 \
# RUN:   | FileCheck %s

# CHECK: :[[@LINE+1]]:1: error: invalid VU0 destination mask
vadd.yx $vf1, $vf2, $vf3
# CHECK: :[[@LINE+1]]:1: error: invalid VU0 destination mask
vadd.xx $vf1, $vf2, $vf3
# CHECK: :[[@LINE+1]]:1: error: invalid VU0 destination mask
vadd.xyq $vf1, $vf2, $vf3

# CHECK: :[[@LINE+1]]:9: error: invalid operand for instruction
vadd.xy $vf32, $vf2, $vf3
# CHECK: :[[@LINE+1]]:9: error: invalid operand for instruction
vadd.xy $vf1x, $vf2, $vf3
# CHECK: :[[@LINE+1]]:10: error: invalid operand for instruction
vdiv $Q, $vf1q, $vf2y
# CHECK: :[[@LINE+1]]:6: error: invalid operand for instruction
vdiv $ACC, $vf1x, $vf2y
