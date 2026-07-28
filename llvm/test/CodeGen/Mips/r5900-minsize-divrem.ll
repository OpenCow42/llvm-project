; RUN: llc -mtriple=mips64el-scei-ps2 -mcpu=r5900 -O2 \
; RUN:   -stop-after=mips-r5900-minsize-divrem -verify-machineinstrs < %s \
; RUN:   | FileCheck %s --check-prefix=MIR
; RUN: llc -mtriple=mips64el-scei-ps2 -mcpu=r5900 -O2 \
; RUN:   -verify-machineinstrs < %s | FileCheck %s --check-prefix=ASM

define i32 @unsigned_quotient(i32 %dividend, i32 %divisor) minsize {
; MIR-LABEL: name: unsigned_quotient
; MIR: R5900_PseudoUDIV_LO
; MIR-NOT: PseudoMFLO
;
; ASM-LABEL: unsigned_quotient:
; ASM:       divu
; ASM-NEXT:  teq
; ASM-NEXT:  mflo
  %result = udiv i32 %dividend, %divisor
  ret i32 %result
}

define i32 @signed_remainder(i32 %dividend, i32 %divisor) minsize {
; MIR-LABEL: name: signed_remainder
; MIR: R5900_PseudoSDIV_HI
; MIR-NOT: PseudoMFHI
;
; ASM-LABEL: signed_remainder:
; ASM:       div
; ASM-NEXT:  teq
; ASM-NEXT:  mfhi
  %result = srem i32 %dividend, %divisor
  ret i32 %result
}

define i32 @two_unsigned_quotients(
    i32 %dividend, i32 %firstDivisor, i32 %secondDivisor
) minsize {
; MIR-LABEL: name: two_unsigned_quotients
; MIR-COUNT-2: R5900_PseudoUDIV_LO
; MIR-NOT: PseudoMFLO
;
; ASM-LABEL: two_unsigned_quotients:
; ASM-NOT:   mtlo
; ASM-NOT:   mthi
; ASM:       divu
; ASM:       mflo
; ASM:       divu
; ASM:       mflo
  %first = udiv i32 %dividend, %firstDivisor
  %second = udiv i32 %dividend, %secondDivisor
  %result = add i32 %first, %second
  ret i32 %result
}

define i32 @quotient_and_remainder(
    i32 %dividend, i32 %divisor
) minsize {
; MIR-LABEL: name: quotient_and_remainder
; MIR:       %[[ACC:[0-9]+]]:acc64 = PseudoUDIV
; MIR:       PseudoMFHI{{.*}}%[[ACC]]
; MIR:       PseudoMFLO{{.*}}%[[ACC]]
; MIR-NOT:   R5900_PseudoUDIV
  %quotient = udiv i32 %dividend, %divisor
  %remainder = urem i32 %dividend, %divisor
  %result = xor i32 %quotient, %remainder
  ret i32 %result
}

define i32 @non_minsize_quotient(i32 %dividend, i32 %divisor) {
; MIR-LABEL: name: non_minsize_quotient
; MIR:       %[[ACC:[0-9]+]]:acc64 = PseudoUDIV
; MIR:       PseudoMFLO{{.*}}%[[ACC]]
; MIR-NOT:   R5900_PseudoUDIV
  %result = udiv i32 %dividend, %divisor
  ret i32 %result
}
