; RUN: llc -mtriple=mips64el-scei-ps2 -mcpu=r5900 < %s | FileCheck %s

; R5900 has 64-bit GPRs but no 64-bit FPU conversion instructions. These
; operations must be expanded instead of using cvt.s.l or cvt.l.s.

define float @signed_i64_to_float(i64 %value) {
; CHECK-NOT: cvt.s.l
; CHECK-NOT: cvt.l.s
; CHECK-LABEL: signed_i64_to_float:
; CHECK: jal __floatdisf
; CHECK-NOT: cvt.s.l
; CHECK-NOT: cvt.l.s
  %result = sitofp i64 %value to float
  ret float %result
}

define float @unsigned_i64_to_float(i64 %value) {
; CHECK-LABEL: unsigned_i64_to_float:
; CHECK: jal __floatdisf
; CHECK: jal __addsf3
; CHECK-NOT: cvt.s.l
; CHECK-NOT: cvt.l.s
  %result = uitofp i64 %value to float
  ret float %result
}

define i64 @float_to_signed_i64(float %value) {
; CHECK-LABEL: float_to_signed_i64:
; CHECK: mfc1
; CHECK-NOT: cvt.l.s
; CHECK-NOT: cvt.s.l
  %result = fptosi float %value to i64
  ret i64 %result
}

define i64 @float_to_unsigned_i64(float %value) {
; CHECK-LABEL: float_to_unsigned_i64:
; CHECK: jal __subsf3
; CHECK-NOT: cvt.l.s
; CHECK-NOT: cvt.s.l
  %result = fptoui float %value to i64
  ret i64 %result
}
