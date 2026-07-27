; RUN: llc -mtriple=mips64el-none-elf -mcpu=r5900 -mattr=+mmi -target-abi n32 \
; RUN:   < %s | FileCheck %s --check-prefix=MMI
; RUN: llc -mtriple=mips64el-none-elf -mcpu=r5900 -mattr=-mmi -target-abi n32 \
; RUN:   < %s | FileCheck %s --check-prefix=SCALAR

declare i32 @llvm.sadd.sat.i32(i32, i32)
declare i32 @llvm.uadd.sat.i32(i32, i32)
declare i32 @llvm.ssub.sat.i32(i32, i32)
declare i32 @llvm.usub.sat.i32(i32, i32)

define i32 @signed_add(i32 %lhs, i32 %rhs) {
; MMI-LABEL: signed_add:
; MMI: paddsw
; MMI-NOT: jal
; SCALAR-LABEL: signed_add:
; SCALAR-NOT: paddsw
  %result = call i32 @llvm.sadd.sat.i32(i32 %lhs, i32 %rhs)
  ret i32 %result
}

define i32 @unsigned_add(i32 %lhs, i32 %rhs) {
; MMI-LABEL: unsigned_add:
; MMI: padduw
; MMI-NOT: jal
; SCALAR-LABEL: unsigned_add:
; SCALAR-NOT: padduw
  %result = call i32 @llvm.uadd.sat.i32(i32 %lhs, i32 %rhs)
  ret i32 %result
}

define i32 @signed_sub(i32 %lhs, i32 %rhs) {
; MMI-LABEL: signed_sub:
; MMI: psubsw
; MMI-NOT: jal
; SCALAR-LABEL: signed_sub:
; SCALAR-NOT: psubsw
  %result = call i32 @llvm.ssub.sat.i32(i32 %lhs, i32 %rhs)
  ret i32 %result
}

define i32 @unsigned_sub(i32 %lhs, i32 %rhs) {
; MMI-LABEL: unsigned_sub:
; MMI: psubuw
; MMI-NOT: jal
; SCALAR-LABEL: unsigned_sub:
; SCALAR-NOT: psubuw
  %result = call i32 @llvm.usub.sat.i32(i32 %lhs, i32 %rhs)
  ret i32 %result
}
