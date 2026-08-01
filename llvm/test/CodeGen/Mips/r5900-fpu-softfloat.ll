; RUN: llc -mtriple=mips64el -mcpu=r5900 < %s | FileCheck %s
;
; Ordinary PS2 Float arithmetic follows the native R5900 single-precision
; behavior. The arithmetic must not be routed through libgcc wrappers.

define float @test_fadd(float %a, float %b) {
; CHECK-LABEL: test_fadd:
; CHECK: add.s
; CHECK-NOT: __addsf3
  %result = fadd float %a, %b
  ret float %result
}

define float @test_fsub(float %a, float %b) {
; CHECK-LABEL: test_fsub:
; CHECK: sub.s
; CHECK-NOT: __subsf3
  %result = fsub float %a, %b
  ret float %result
}

define float @test_fmul(float %a, float %b) {
; CHECK-LABEL: test_fmul:
; CHECK: mul.s
; CHECK-NOT: __mulsf3
  %result = fmul float %a, %b
  ret float %result
}

define float @test_fdiv(float %a, float %b) {
; CHECK-LABEL: test_fdiv:
; CHECK: div.s
; CHECK-NOT: __divsf3
  %result = fdiv float %a, %b
  ret float %result
}

define float @test_fsqrt(float %a) {
; CHECK-LABEL: test_fsqrt:
; CHECK: jal sqrtf
  %result = call float @llvm.sqrt.f32(float %a)
  ret float %result
}

; Fast-math flags do not change the native instruction selection.
define float @test_fadd_nnan_ninf(float %a, float %b) {
; CHECK-LABEL: test_fadd_nnan_ninf:
; CHECK: add.s
  %result = fadd nnan ninf float %a, %b
  ret float %result
}

define float @test_fsub_nnan_ninf(float %a, float %b) {
; CHECK-LABEL: test_fsub_nnan_ninf:
; CHECK: sub.s
  %result = fsub nnan ninf float %a, %b
  ret float %result
}

define float @test_fmul_nnan_ninf(float %a, float %b) {
; CHECK-LABEL: test_fmul_nnan_ninf:
; CHECK: mul.s
  %result = fmul nnan ninf float %a, %b
  ret float %result
}

define float @test_fdiv_nnan_ninf(float %a, float %b) {
; CHECK-LABEL: test_fdiv_nnan_ninf:
; CHECK: div.s
  %result = fdiv nnan ninf float %a, %b
  ret float %result
}

define float @test_fsqrt_nnan_ninf(float %a) {
; CHECK-LABEL: test_fsqrt_nnan_ninf:
; CHECK: sqrt.s
  %result = call nnan ninf float @llvm.sqrt.f32(float %a)
  ret float %result
}

declare float @llvm.sqrt.f32(float)
