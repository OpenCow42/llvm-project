; RUN: llc -mtriple=mips64el-scei-ps2 -mcpu=r5900 -mattr=+vu0 < %s | FileCheck %s --check-prefixes=VU0,N32
; RUN: llc -mtriple=mips64el-scei-ps2 -mcpu=r5900 -mattr=-vu0 < %s | FileCheck %s --check-prefix=NO-VU0

; VU0 vector values remain local to leaf kernels. All public parameters and
; results cross the N32 boundary as 32-bit pointers.

define void @vu0_add(ptr %lhs, ptr %rhs, ptr %result) {
; VU0-LABEL: vu0_add:
; VU0: lqc2
; VU0: lqc2
; VU0: vadd.xyzw
; VU0: sqc2
; N32-NOT: qmfc2
; N32-NOT: qmtc2
; NO-VU0-LABEL: vu0_add:
; NO-VU0-NOT: lqc2
; NO-VU0-NOT: sqc2
; NO-VU0-NOT: vadd
  %a = load <4 x float>, ptr %lhs, align 16
  %b = load <4 x float>, ptr %rhs, align 16
  %sum = fadd <4 x float> %a, %b
  store <4 x float> %sum, ptr %result, align 16
  ret void
}

define void @vu0_mul_add(ptr %lhs, ptr %rhs, ptr %addend, ptr %result) {
; VU0-LABEL: vu0_mul_add:
; VU0: vmul.xyzw
; VU0: vadd.xyzw
; VU0: sqc2
; NO-VU0-LABEL: vu0_mul_add:
; NO-VU0-NOT: vmul
; NO-VU0-NOT: vadd
  %a = load <4 x float>, ptr %lhs, align 16
  %b = load <4 x float>, ptr %rhs, align 16
  %c = load <4 x float>, ptr %addend, align 16
  %product = fmul <4 x float> %a, %b
  %sum = fadd <4 x float> %product, %c
  store <4 x float> %sum, ptr %result, align 16
  ret void
}

define void @vu0_mat4_mul_vec4(ptr %columns, ptr %vector, ptr %result) {
; VU0-LABEL: vu0_mat4_mul_vec4:
; N32: .frame $sp,0,$ra
; VU0-COUNT-5: lqc2
; VU0-NOT: lw
; VU0-NOT: sw
; VU0: vmulax.xyzw
; VU0-NEXT: vmadday.xyzw
; VU0-NEXT: vmaddaz.xyzw
; VU0-NEXT: vmaddw.xyzw
; VU0: sqc2
; VU0-NOT: lqc2
; VU0-NOT: sqc2
; VU0-NOT: qmfc2
; VU0-NOT: qmtc2
; VU0: .end vu0_mat4_mul_vec4
; NO-VU0-LABEL: vu0_mat4_mul_vec4:
; NO-VU0-NOT: vmul
  %column0 = load <4 x float>, ptr %columns, align 16
  %column1.pointer = getelementptr <4 x float>, ptr %columns, i32 1
  %column1 = load <4 x float>, ptr %column1.pointer, align 16
  %column2.pointer = getelementptr <4 x float>, ptr %columns, i32 2
  %column2 = load <4 x float>, ptr %column2.pointer, align 16
  %column3.pointer = getelementptr <4 x float>, ptr %columns, i32 3
  %column3 = load <4 x float>, ptr %column3.pointer, align 16
  %value = load <4 x float>, ptr %vector, align 16
  %x = shufflevector <4 x float> %value, <4 x float> poison,
                     <4 x i32> zeroinitializer
  %y = shufflevector <4 x float> %value, <4 x float> poison,
                     <4 x i32> <i32 1, i32 1, i32 1, i32 1>
  %z = shufflevector <4 x float> %value, <4 x float> poison,
                     <4 x i32> <i32 2, i32 2, i32 2, i32 2>
  %w = shufflevector <4 x float> %value, <4 x float> poison,
                     <4 x i32> <i32 3, i32 3, i32 3, i32 3>
  %x.product = fmul fast <4 x float> %column0, %x
  %y.product = fmul fast <4 x float> %column1, %y
  %z.product = fmul fast <4 x float> %column2, %z
  %w.product = fmul fast <4 x float> %column3, %w
  %xy = fadd fast <4 x float> %x.product, %y.product
  %xyz = fadd fast <4 x float> %xy, %z.product
  %xyzw = fadd fast <4 x float> %xyz, %w.product
  store <4 x float> %xyzw, ptr %result, align 16
  ret void
}

; Strict floating-point expressions still use VF registers, but do not contract
; through ACC without explicit reassociation and contraction permission.
define void @vu0_strict_two_term(ptr %columns, ptr %vector, ptr %result) {
; VU0-LABEL: vu0_strict_two_term:
; VU0: vmulx.xyzw
; VU0: vmuly.xyzw
; VU0: vadd.xyzw
; VU0-NOT: vmulax
; VU0-NOT: vmadday
  %column0 = load <4 x float>, ptr %columns, align 16
  %column1.pointer = getelementptr <4 x float>, ptr %columns, i32 1
  %column1 = load <4 x float>, ptr %column1.pointer, align 16
  %value = load <4 x float>, ptr %vector, align 16
  %x = shufflevector <4 x float> %value, <4 x float> poison,
                     <4 x i32> zeroinitializer
  %y = shufflevector <4 x float> %value, <4 x float> poison,
                     <4 x i32> <i32 1, i32 1, i32 1, i32 1>
  %x.product = fmul <4 x float> %column0, %x
  %y.product = fmul <4 x float> %column1, %y
  %sum = fadd <4 x float> %x.product, %y.product
  store <4 x float> %sum, ptr %result, align 16
  ret void
}
