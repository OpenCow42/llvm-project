# RUN: llvm-mc %s -triple=mips64el-scei-ps2 -mcpu=r5900 -mattr=+vu0 -show-encoding | FileCheck %s
# RUN: not llvm-mc %s -triple=mips64el-scei-ps2 -mcpu=r5900 -mattr=-vu0 2>&1 | FileCheck %s --check-prefix=NO-VU0

.set noreorder

# Destination masks and the arithmetic/ACC families.
# CHECK: vadd.xy{{.*}}encoding: [0x68,0x10,0x83,0x4b]
vadd.xy $vf1, $vf2, $vf3
# CHECK: vsub.zw{{.*}}encoding: [0x2c,0x29,0x66,0x4a]
vsub.zw $vf4, $vf5, $vf6
# CHECK: vmul.xz{{.*}}encoding: [0xea,0x41,0x49,0x4b]
vmul.xz $vf7, $vf8, $vf9
# CHECK: vmax.yw{{.*}}encoding: [0xab,0x5a,0xac,0x4a]
vmax.yw $vf10, $vf11, $vf12
# CHECK: vmini.xyz{{.*}}encoding: [0x6f,0x73,0xcf,0x4b]
vmini.xyz $vf13, $vf14, $vf15
# CHECK: vabs.xyzw{{.*}}encoding: [0xfd,0x89,0xf0,0x4b]
vabs.xyzw $vf16, $vf17
# CHECK: vmove.xy{{.*}}encoding: [0x3c,0x9b,0x92,0x4b]
vmove.xy $vf18, $vf19
# CHECK: vmr32.zw{{.*}}encoding: [0x3d,0xab,0x74,0x4a]
vmr32.zw $vf20, $vf21
# CHECK: vadda.xyzw $ACC,{{.*}}encoding: [0xbc,0x12,0xe1,0x4b]
vadda.xyzw $ACC, $vf1, $vf2
# CHECK: vmula.xyzw $ACC,{{.*}}encoding: [0xbe,0x1a,0xe4,0x4b]
vmula.xyzw $ACC, $vf3, $vf4
# CHECK: vmadda.xyzw $ACC,{{.*}}encoding: [0xbd,0x2a,0xe6,0x4b]
vmadda.xyzw $ACC, $vf5, $vf6
# CHECK: vmsuba.xyzw $ACC,{{.*}}encoding: [0xfd,0x42,0xe7,0x4b]
vmsuba.xyzw $ACC, $vf7, $vf8

# Broadcast, Q, outer-product, and control paths.
# CHECK: vmulx.xyzw{{.*}}encoding: [0x58,0x52,0xeb,0x4b]
vmulx.xyzw $vf9, $vf10, $vf11
# CHECK: vmadday.xyzw $ACC,{{.*}}encoding: [0xbd,0x60,0xed,0x4b]
vmadday.xyzw $ACC, $vf12, $vf13
# CHECK: vmulq.xyzw{{.*}}$Q{{.*}}encoding: [0x9c,0x7b,0xe0,0x4b]
vmulq.xyzw $vf14, $vf15, $Q
# CHECK: vaddq.xy{{.*}}$Q{{.*}}encoding: [0x20,0x8c,0x80,0x4b]
vaddq.xy $vf16, $vf17, $Q
# CHECK: vopmula.xyz $ACC,{{.*}}encoding: [0xfe,0x92,0xd3,0x4b]
vopmula.xyz $ACC, $vf18, $vf19
# CHECK: vopmsub.xyz{{.*}}encoding: [0x2e,0xad,0xd6,0x4b]
vopmsub.xyz $vf20, $vf21, $vf22
# CHECK: vclipw.xyz{{.*}}encoding: [0xff,0xb9,0xd8,0x4b]
vclipw.xyz $vf23, $vf24
# CHECK: vdiv $Q,{{.*}}encoding: [0xbc,0x0b,0x82,0x4a]
vdiv $Q, $vf1x, $vf2y
# CHECK: vrsqrt $Q,{{.*}}encoding: [0xbe,0x1b,0xc4,0x4b]
vrsqrt $Q, $vf3z, $vf4w
# CHECK: vsqrt $Q,{{.*}}encoding: [0xbd,0x03,0x25,0x4a]
vsqrt $Q, $vf5x
# CHECK: vwaitq{{.*}}encoding: [0xbf,0x03,0x00,0x4a]
vwaitq
# CHECK: vnop{{.*}}encoding: [0xff,0x02,0x00,0x4a]
vnop
# CHECK: cfc2{{.*}}encoding: [0x00,0x80,0x44,0x48]
cfc2 $4, $16
# CHECK: ctc2{{.*}}encoding: [0x00,0x88,0xc5,0x48]
ctc2 $5, $17
# CTC2 to VI21 supplies the VU I scalar control path.
# CHECK: ctc2{{.*}}encoding: [0x00,0xa8,0xc5,0x48]
ctc2 $5, $21
# CHECK: qmfc2{{.*}}encoding: [0x00,0xc8,0x26,0x48]
qmfc2 $6, $vf25
# CHECK: qmtc2{{.*}}encoding: [0x00,0xd0,0xa7,0x48]
qmtc2 $7, $vf26

# NO-VU0: error: instruction requires a CPU feature not currently enabled
