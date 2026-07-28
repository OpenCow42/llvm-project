; RUN: llc -mtriple=mips64el-scei-ps2 -mcpu=r5900 -relocation-model=static \
; RUN:   -verify-machineinstrs < %s | FileCheck %s --check-prefixes=PS2,PS2-STATIC
; RUN: llc -mtriple=mips64el-scei-ps2 -mcpu=r5900 -relocation-model=pic \
; RUN:   -verify-machineinstrs < %s | FileCheck %s --check-prefixes=PS2,PS2-PIC
; RUN: llc -mtriple=mips64el-unknown-elf -mcpu=r5900 -relocation-model=static \
; RUN:   -verify-machineinstrs < %s | FileCheck %s --check-prefix=GENERIC

define internal i32 @implementation(i32 %value, i32 %bias) noinline nounwind {
entry:
  %sum = add i32 %value, %bias
  ret i32 %sum
}

define i32 @static_wrapper(i32 %value) nounwind {
; PS2-LABEL: static_wrapper:
; PS2-STATIC: j implementation
; PS2-PIC:   jr $25
; PS2-NEXT:  addiu $5, $zero, 32
; PS2-NOT:   jal
; PS2-NOT:   addiu $sp, $sp,
; GENERIC-LABEL: static_wrapper:
; GENERIC:   jal
  %result = tail call i32 @implementation(i32 %value, i32 32)
  ret i32 %result
}

define internal fastcc i64 @pointer_implementation(
    ptr %context, i32 signext %count) noinline minsize nounwind {
entry:
  %value = load i64, ptr %context, align 8
  %extended = sext i32 %count to i64
  %sum = add i64 %value, %extended
  ret i64 %sum
}

define i64 @pointer_wrapper(ptr %context) minsize nounwind {
; PS2-LABEL: pointer_wrapper:
; PS2-STATIC-NOT: sll
; PS2-STATIC: j pointer_implementation
; PS2-PIC:   jr $25
; PS2-NEXT:  addiu $5, $zero, 32
; PS2-NOT:   jal
; PS2-NOT:   addiu $sp, $sp,
  %result =
      tail call fastcc i64 @pointer_implementation(ptr %context, i32 32)
  ret i64 %result
}

define i32 @tail_calls_disabled(i32 %value) nounwind
    "disable-tail-calls"="true" {
; PS2-LABEL: tail_calls_disabled:
; PS2:       addiu $sp, $sp, -16
; PS2-STATIC: jal implementation
; PS2-PIC:   jalr $25
; PS2:       jr $ra
; PS2:       addiu $sp, $sp, 16
  %result = tail call i32 @implementation(i32 %value, i32 128)
  ret i32 %result
}

declare i32 @external_implementation(i32)

define i32 @external_wrapper(i32 %value) nounwind {
; PS2-LABEL: external_wrapper:
; PS2-STATIC: jal external_implementation
; PS2-PIC:   jalr $25
; PS2-STATIC-NOT: j external_implementation
  %result = tail call i32 @external_implementation(i32 %value)
  ret i32 %result
}
