; RUN: llc -O0 -mtriple=mips64el -mcpu=r5900 < %s | FileCheck %s
;
; Direct floating-point branches may invert their SETCC after operation
; legalization. Ensure the final R5900 lowering boundary canonicalizes those
; inverted predicates back to the four comparisons implemented by the EE FPU.

define void @branch_ogt(float %a, float %b, ptr %output) {
; CHECK-LABEL: branch_ogt:
; CHECK:       c.olt.s $f13, $f12
; CHECK-NOT:   c.ule.s
entry:
  %compare = fcmp ogt float %a, %b
  br i1 %compare, label %true, label %exit

true:
  store i32 1, ptr %output, align 4
  br label %exit

exit:
  ret void
}

define void @branch_oge(float %a, float %b, ptr %output) {
; CHECK-LABEL: branch_oge:
; CHECK:       c.ole.s $f13, $f12
; CHECK-NOT:   c.ult.s
entry:
  %compare = fcmp oge float %a, %b
  br i1 %compare, label %true, label %exit

true:
  store i32 1, ptr %output, align 4
  br label %exit

exit:
  ret void
}

define void @branch_ult(float %a, float %b, ptr %output) {
; CHECK-LABEL: branch_ult:
; CHECK:       c.ole.s $f13, $f12
; CHECK-NOT:   c.ult.s
entry:
  %compare = fcmp ult float %a, %b
  br i1 %compare, label %true, label %exit

true:
  store i32 1, ptr %output, align 4
  br label %exit

exit:
  ret void
}

define void @branch_ule(float %a, float %b, ptr %output) {
; CHECK-LABEL: branch_ule:
; CHECK:       c.olt.s $f13, $f12
; CHECK-NOT:   c.ule.s
entry:
  %compare = fcmp ule float %a, %b
  br i1 %compare, label %true, label %exit

true:
  store i32 1, ptr %output, align 4
  br label %exit

exit:
  ret void
}
