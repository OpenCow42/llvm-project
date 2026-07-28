; RUN: opt -mtriple=mips64el-scei-ps2 -mcpu=r5900 \
; RUN:   -passes='print<cost-model>' -disable-output < %s 2>&1 \
; RUN:   | FileCheck %s --check-prefix=R5900
; RUN: opt -mtriple=mips64el-unknown-elf -mcpu=mips64 \
; RUN:   -passes='print<cost-model>' -disable-output < %s 2>&1 \
; RUN:   | FileCheck %s --check-prefix=GENERIC

define i64 @constant_multiply_costs(i64 %value, i64 %other) {
; R5900-LABEL: Printing analysis 'Cost Model Analysis' for function 'constant_multiply_costs':
; R5900: Cost Model: Found an estimated cost of 2 for instruction: %simple = mul i64 %value, 33
; R5900: Cost Model: Found an estimated cost of 10 for instruction: %complex = mul i64 %simple, 1099511628211
; R5900: Cost Model: Found an estimated cost of 3 for instruction: %negative = mul i64 %complex, -33
; R5900: Cost Model: Found an estimated cost of 2 for instruction: %variable = mul i64 %negative, %other
; GENERIC-LABEL: Printing analysis 'Cost Model Analysis' for function 'constant_multiply_costs':
; GENERIC: Cost Model: Found an estimated cost of 2 for instruction: %simple = mul i64 %value, 33
; GENERIC: Cost Model: Found an estimated cost of 2 for instruction: %complex = mul i64 %simple, 1099511628211
; GENERIC: Cost Model: Found an estimated cost of 2 for instruction: %negative = mul i64 %complex, -33
; GENERIC: Cost Model: Found an estimated cost of 2 for instruction: %variable = mul i64 %negative, %other
  %simple = mul i64 %value, 33
  %complex = mul i64 %simple, 1099511628211
  %negative = mul i64 %complex, -33
  %variable = mul i64 %negative, %other
  ret i64 %variable
}
