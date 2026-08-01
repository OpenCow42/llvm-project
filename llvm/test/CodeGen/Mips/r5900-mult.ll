; RUN: llc -mtriple=mips64el-scei-ps2 -mcpu=r5900 -O2 < %s | FileCheck %s

define i32 @multiply_i32(i32 %lhs, i32 %rhs) {
; CHECK-LABEL: multiply_i32:
; CHECK: mult ${{[0-9]+}}, ${{[0-9]+}}, ${{[0-9]+}}
; CHECK-NOT: mflo
  %result = mul i32 %lhs, %rhs
  ret i32 %result
}

define i32 @multiply_fnv_prime(i32 %value) {
; CHECK-LABEL: multiply_fnv_prime:
; CHECK: mult ${{[0-9]+}}, ${{[0-9]+}}, ${{[0-9]+}}
; CHECK-NOT: mflo
  %result = mul i32 %value, 16777619
  ret i32 %result
}

define i32 @multiply_by_33(i32 %value) {
; CHECK-LABEL: multiply_by_33:
; CHECK: sll
; CHECK: addu
; CHECK-NOT: {{[[:space:]]}}mult{{[[:space:]]}}
  %result = mul i32 %value, 33
  ret i32 %result
}

define i64 @multiply_i64(i64 %lhs, i64 %rhs) {
; CHECK-LABEL: multiply_i64:
; CHECK-NOT: dmult
; CHECK-NOT: dmultu
; CHECK-NOT: __muldi3
  %result = mul i64 %lhs, %rhs
  ret i64 %result
}

declare void @observe()

define i64 @multiply_i64_minsize_leaf(i64 %lhs, i64 %rhs) minsize {
; CHECK-LABEL: multiply_i64_minsize_leaf:
; CHECK-NOT: __muldi3
  %result = mul i64 %lhs, %rhs
  ret i64 %result
}

define i64 @multiply_i64_minsize_nonleaf(i64 %lhs, i64 %rhs) minsize {
; CHECK-LABEL: multiply_i64_minsize_nonleaf:
; CHECK-NOT: __muldi3
; CHECK: jal observe
  call void @observe()
  %result = mul i64 %lhs, %rhs
  ret i64 %result
}

define i64 @multiply_fnv64_minsize_leaf(i64 %value) minsize {
; CHECK-LABEL: multiply_fnv64_minsize_leaf:
; CHECK-NOT: __muldi3
; CHECK: dsll
  %result = mul i64 %value, 1099511628211
  ret i64 %result
}

define i64 @multiply_fnv64_minsize_nonleaf(i64 %value) minsize {
; CHECK-LABEL: multiply_fnv64_minsize_nonleaf:
; CHECK: jal __muldi3
; CHECK: jal observe
  call void @observe()
  %result = mul i64 %value, 1099511628211
  ret i64 %result
}

define i64 @multiply_by_33_minsize_nonleaf(i64 %value) minsize {
; CHECK-LABEL: multiply_by_33_minsize_nonleaf:
; CHECK-NOT: __muldi3
; CHECK: dsll
; CHECK: jal observe
  call void @observe()
  %result = mul i64 %value, 33
  ret i64 %result
}

define i64 @multiply_fnv64_non_minsize_nonleaf(i64 %value) {
; CHECK-LABEL: multiply_fnv64_non_minsize_nonleaf:
; CHECK-NOT: __muldi3
; CHECK: dsll
; CHECK: jal observe
  call void @observe()
  %result = mul i64 %value, 1099511628211
  ret i64 %result
}
