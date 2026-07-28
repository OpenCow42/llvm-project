; RUN: opt -mtriple=mips64el-scei-ps2 -mcpu=r5900 \
; RUN:   -passes='loop-unroll-full' -S < %s \
; RUN:   | FileCheck %s --check-prefix=R5900
; RUN: opt -mtriple=mips64el-unknown-elf -mcpu=mips64 \
; RUN:   -passes='loop-unroll-full' -S < %s \
; RUN:   | FileCheck %s --check-prefix=GENERIC

define i64 @complex_multiply_loop(ptr nocapture readonly %values) {
; R5900-LABEL: define i64 @complex_multiply_loop(
; R5900: loop:
; R5900: %acc = phi i64
; R5900: %next = mul i64 %mixed, 1099511628211
; R5900: br i1 %done, label %exit, label %loop
; R5900-NOT: %next.1 = mul i64
; GENERIC-LABEL: define i64 @complex_multiply_loop(
; GENERIC-NOT: phi i64
; GENERIC: mul i64 {{.*}}, 1099511628211
; GENERIC: mul i64 {{.*}}, 1099511628211
; GENERIC: mul i64 {{.*}}, 1099511628211
; GENERIC: mul i64 {{.*}}, 1099511628211
entry:
  br label %loop

loop:
  %index = phi i32 [ 0, %entry ], [ %increment, %loop ]
  %acc = phi i64 [ 1469598103934665603, %entry ], [ %next, %loop ]
  %element = getelementptr inbounds i64, ptr %values, i32 %index
  %value = load i64, ptr %element, align 8
  %mixed = xor i64 %acc, %value
  %next = mul i64 %mixed, 1099511628211
  %increment = add nuw nsw i32 %index, 1
  %done = icmp eq i32 %increment, 4
  br i1 %done, label %exit, label %loop

exit:
  ret i64 %next
}

define i64 @simple_multiply_loop(ptr nocapture readonly %values) {
; R5900-LABEL: define i64 @simple_multiply_loop(
; R5900-NOT: phi i64
; R5900: mul i64 {{.*}}, 33
; R5900: mul i64 {{.*}}, 33
; R5900: mul i64 {{.*}}, 33
; R5900: mul i64 {{.*}}, 33
entry:
  br label %loop

loop:
  %index = phi i32 [ 0, %entry ], [ %increment, %loop ]
  %acc = phi i64 [ 1, %entry ], [ %next, %loop ]
  %element = getelementptr inbounds i64, ptr %values, i32 %index
  %value = load i64, ptr %element, align 8
  %mixed = xor i64 %acc, %value
  %next = mul i64 %mixed, 33
  %increment = add nuw nsw i32 %index, 1
  %done = icmp eq i32 %increment, 4
  br i1 %done, label %exit, label %loop

exit:
  ret i64 %next
}
