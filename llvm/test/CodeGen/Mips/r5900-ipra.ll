; RUN: llc -mtriple=mips64el-scei-ps2 -mcpu=r5900 -O2 \
; RUN:   -verify-machineinstrs < %s | FileCheck %s --check-prefix=IPRA
; RUN: llc -mtriple=mips64el-scei-ps2 -mcpu=r5900 -O2 -enable-ipra=0 \
; RUN:   -verify-machineinstrs < %s | FileCheck %s --check-prefix=NO-IPRA
; RUN: llc -mtriple=mips64el-unknown-elf -mcpu=r5900 -O2 \
; RUN:   -verify-machineinstrs < %s | FileCheck %s --check-prefix=NO-IPRA

define internal i32 @leaf(i32 %value) noinline nounwind readnone {
entry:
  %shifted = shl i32 %value, 5
  %result = xor i32 %shifted, 1515870810
  ret i32 %result
}

define i32 @call_depth_pressure(i32 %a, i32 %b, i32 %c, i32 %d,
                                i32 %e, i32 %f, i32 %g, i32 %h) nounwind {
; IPRA-LABEL: call_depth_pressure:
; IPRA:       .frame $sp,16,$ra
; IPRA-NOT:   s{{[wd]}} $16
; IPRA-NOT:   s{{[wd]}} $17
; IPRA-NOT:   s{{[wd]}} $18
; IPRA:       jal leaf
; IPRA-NOT:   l{{[wd]}} $16
; IPRA-NOT:   l{{[wd]}} $17
; IPRA-NOT:   l{{[wd]}} $18
; NO-IPRA-LABEL: call_depth_pressure:
; NO-IPRA:       .frame $sp,16,$ra
; NO-IPRA:       s{{[wd]}} $16
; NO-IPRA:       jal leaf
; NO-IPRA:       l{{[wd]}} $16
entry:
  %call = call i32 @leaf(i32 %a)
  %ab = add i32 %a, %b
  %abc = add i32 %ab, %c
  %abcd = add i32 %abc, %d
  %abcde = add i32 %abcd, %e
  %abcdef = add i32 %abcde, %f
  %abcdefg = add i32 %abcdef, %g
  %abcdefgh = add i32 %abcdefg, %h
  %result = add i32 %abcdefgh, %call
  ret i32 %result
}
